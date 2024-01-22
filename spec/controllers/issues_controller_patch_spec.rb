require "spec_helper"
require "active_support/testing/assertions"
require_relative '../../lib/redmine_unregistered_watchers/issues_controller_patch.rb'
require_relative '../../lib/redmine_unregistered_watchers/issue_patch.rb'

describe IssuesController, type: :controller do
  render_views
  include ActiveSupport::Testing::Assertions

  fixtures :unregistered_watchers,
           :unregistered_watchers_notifications,
           :users, :email_addresses, :user_preferences,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets,
           :projects

  before do
    @request.session[:user_id] = 2
    EnabledModule.create!(:project_id => 1, :name => "unregistered_watchers")
    Setting.plain_text_mail = 0
    Setting.default_language = 'en'
    Setting["plugin_redmine_unregistered_watchers"]["emails_signature_for_unregistered_watchers"] = "The A Team for issue <<id>>"
    Setting["plugin_redmine_unregistered_watchers"]["emails_footer_for_unregistered_watchers"] = "You received this message because you have been registered as watcher on this issue."
  end

  let!(:recipient_field) { Redmine::VERSION::MAJOR >= 5 ? 'to' : 'bcc' }

  it "should send a notification to unregistered watchers after create" do
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.size', 3 do
      assert_difference 'Issue.count' do
        post :create, params: { :project_id => 1,
                                :issue => { :tracker_id => 3,
                                            :subject => 'This is the test_new issue',
                                            :description => 'This is the description',
                                            :priority_id => 5,
                                            :unregistered_watchers => ["captain@example.com",
                                                                       "boss@email.com",
                                                                       "some_provider@example.com"],
                                            :notif_sent_to_unreg_watchers => true,
                                            :custom_field_values => { '2' => 'Value for field 2' } } }
      end
    end

    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    expect(ActionMailer::Base.deliveries.size).to eq 3

    default_mail = ActionMailer::Base.deliveries.second

    expect(default_mail[recipient_field].value).to include User.find(2).mail
    expect(default_mail[recipient_field].value).to_not include "captain@example.com"
    expect(default_mail[recipient_field].value).to_not include "boss@email.com"
    expect(default_mail[recipient_field].value).to_not include "some_provider@example.com"
    default_mail.parts.each do |part|
      expect(part.body.raw_source).to include "has been reported by"
      expect(part.body.raw_source).to_not include "Email body content"
    end

    unregistered_watchers_email = ActionMailer::Base.deliveries.first
    expect(unregistered_watchers_email[recipient_field].value).to_not include User.find(2).mail
    expect(unregistered_watchers_email[recipient_field].value).to include "captain@example.com"
    expect(unregistered_watchers_email[recipient_field].value).to include "boss@email.com"
    expect(unregistered_watchers_email[recipient_field].value).to include "some_provider@example.com"
    unregistered_watchers_email.parts.each do |part|
      expect(part.body.raw_source).to_not include "has been reported by"
      expect(part.body.raw_source).to include "Email body content for status 2"
      # expect(part.body.raw_source).to include "The A Team for issue <<id>>" # Signature automatically added
      # expect(part.body.raw_source).to include "you have been registered as watcher" # Footer
    end
  end

  it "should send a notification to unregistered watchers after create unless sent notif check box has been unchecked" do
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.size', 3 do
      assert_difference 'Issue.count' do
        post :create, params: { :project_id => 1,
                                :issue => { :tracker_id => 3,
                                            :subject => 'This is the test_new issue',
                                            :description => 'This is the description',
                                            :priority_id => 5,
                                            :estimated_hours => '',
                                            :unregistered_watchers => ["captain@example.com", "boss@email.com"],
                                            :notif_sent_to_unreg_watchers => false,
                                            :custom_field_values => { '2' => 'Value for field 2' } } }
      end
    end

    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    expect(ActionMailer::Base.deliveries.size).to eq 3 # Only default notification to REGISTERED watchers
    default_mail = ActionMailer::Base.deliveries.second
    expect(default_mail[recipient_field].value).to include(User.find(2).mail)
    expect(default_mail[recipient_field].value).to_not include("captain@example.com")
    expect(default_mail[recipient_field].value).to_not include("boss@email.com")
    default_mail.parts.each do |part|
      expect(part.body.raw_source).to include("has been reported by")
      expect(part.body.raw_source).to_not include("Email body content")
    end

  end

  it "should send a notification to unregistered watchers after update and create journal details" do
    ActionMailer::Base.deliveries.clear

    content = "Custom body: the issue has been closed !"

    UnregisteredWatchersNotification.create!(:issue_status_id => 5, :project_id => 1, :email_body => content)

    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 3) do
        put :update, params: { :id => 1,
                               :issue => { unregistered_watchers: ["captain@example.com",
                                                                   "another@email.com",
                                                                   "msjoe@example.com",
                                                                   "mrjohn@example.com"],
                                           notif_sent_to_unreg_watchers: true,
                                           status_id: '5' # close issue
                               } }
      end
    end
    expect(ActionMailer::Base.deliveries.size).to eq 3

    default_mail = ActionMailer::Base.deliveries.second
    unregistered_watchers_email = ActionMailer::Base.deliveries.first

    expect(default_mail[recipient_field].value).to include User.find(2).mail
    expect(default_mail[recipient_field].value).to_not include "captain@example.com"
    expect(default_mail[recipient_field].value).to_not include "boss@email.com"
    default_mail.parts.each do |part|
      expect(part.body.raw_source).to include "has been updated by"
      expect(part.body.raw_source).to_not include content
    end

    expect(unregistered_watchers_email[recipient_field].value).to_not include User.find(2).mail
    expect(unregistered_watchers_email[recipient_field].value).to include "captain@example.com"
    expect(unregistered_watchers_email[recipient_field].value).to_not include "boss@email.com"
    unregistered_watchers_email.parts.each do |part|
      expect(part.body.raw_source).to_not include "has been updated by"
      expect(part.body.raw_source).to include content
    end
  end

  it "does NOT send a notification to unregistered watchers after update if notification message is empty" do
    ActionMailer::Base.deliveries.clear

    content = "Custom body: the issue has been closed !"

    UnregisteredWatchersNotification.create!(:issue_status_id => 5, :project_id => 1, :email_body => "") # EMPTY BODY

    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 3) do
        put :update, params: { :id => 1,
                               :issue => { unregistered_watchers: ["captain@example.com",
                                                                   "another@email.com",
                                                                   "msjoe@example.com",
                                                                   "mrjohn@example.com"],
                                           notif_sent_to_unreg_watchers: true,
                                           status_id: '5' # close issue
                               } }
      end
    end
    expect(ActionMailer::Base.deliveries.size).to eq 2

    default_mail = ActionMailer::Base.deliveries.first

    expect(default_mail[recipient_field].value).to include User.find(2).mail
    expect(default_mail[recipient_field].value).to_not include "captain@example.com"
    expect(default_mail[recipient_field].value).to_not include "boss@email.com"
    default_mail.parts.each do |part|
      expect(part.body.raw_source).to include "has been updated by"
      expect(part.body.raw_source).to_not include content
    end
  end

  it "should send a notification to unregistered watchers after update and create journal details unless sent notif check box has been unchecked" do
    ActionMailer::Base.deliveries.clear

    content = "Custom body: the issue has been closed !"

    UnregisteredWatcher.create!(issue_id: 1, email: "captain@example.com")
    UnregisteredWatchersNotification.create!(:issue_status_id => 5, :project_id => 1, :email_body => content)

    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 3) do
        put :update, params: { id: 1,
                               issue: { unregistered_watchers: ["captain@example.com",
                                                                "another@email.com"],
                                        notif_sent_to_unreg_watchers: false,
                                        status_id: '5' # close issue
                               } }
      end
    end
    expect(ActionMailer::Base.deliveries.size).to eq 3 # Only default notification to REGISTERED watchers
    default_mails = ActionMailer::Base.deliveries.select { |mail|
      mail['subject'].value == "[eCookbook - Bug #1] (Closed) Cannot print recipes"
    }
    default_mails_recipients = default_mails.map { |m| m[recipient_field].value }.flatten.uniq
    expect(default_mails_recipients).to include(User.find(2).mail)
    expect(default_mails_recipients).to_not include("captain@example.com")
    expect(default_mails_recipients).to_not include("boss@email.com")
    default_mails.first.parts.each do |part|
      expect(part.body.raw_source).to include "has been updated by"
      expect(part.body.raw_source).to_not include content
    end

  end

  describe "Resend notification to the unregistered watchers" do

    before do
      UnregisteredWatchersHistory.create(issue_status_id: 3,
                                         issue_id: 1,
                                         content: "the issue has been closed !",
                                         to: "captain@example.com",
                                         subject: "[project_test] Feature request")

      User.current = User.find(3)
      @request.session[:user_id] = 3
      Role.find(2).add_permission!(:resend_unregistered_watchers_notification)
    end

    it "does not show the link (resend this notification) without permission" do
      Role.find(2).remove_permission!(:resend_unregistered_watchers_notification)
      get :show, params: { :id => 1 }
      expect(response.body).not_to have_content('Resend this email')
    end

    it "shows the link (resend this notification) with permission" do
      get :show, params: { :id => 1 }
      expect(response.body).to have_content('Resend this email')
    end

    it "resends the notification to the unregistered watchers" do
      last_history = UnregisteredWatchersHistory.last

      expect do
        post :resend_unregistered_watchers_notification, params: { issue_id: 1, history_id: last_history["id"] }
      end.to change { Journal.count }.by(1)
                                     .and change { ActionMailer::Base.deliveries.size }.by(1)

      expect(response).to redirect_to("/issues/1")

      last_journal = Journal.last
      expect(last_journal.journalized_type).to eq "UnregisteredWatchersHistory"
      expect(last_journal.journalized_id).to eq last_history["id"]
      expect(last_journal.notes).to eq last_history["content"]
    end

    it "does not resend the notification to the unregistered watchers if the user has no permission" do
      Role.find(2).remove_permission!(:resend_unregistered_watchers_notification)
      last_history = UnregisteredWatchersHistory.last

      expect do
        post :resend_unregistered_watchers_notification, params: { issue_id: 1, history_id: last_history["id"] }
      end.to_not change { ActionMailer::Base.deliveries.size }

      expect(response).to have_http_status(:forbidden) # 403
    end
  end

  describe "messages by tracker" do

    let!(:content_for_tracker_1) { "[Bug] the issue has been open and assigned to you !" }
    let!(:content_for_tracker_2) { "Feature request: the issue has been open !" }

    before do
      Project.update({ :unreg_watchers_all_trackers => false, :unreg_watchers_tracker_ids => [1, 2] })

      UnregisteredWatchersNotification.create!(:issue_status_id => 1,
                                               :project_id => 1,
                                               :email_body => content_for_tracker_1,
                                               :tracker_id => 1)

      UnregisteredWatchersNotification.create!(:issue_status_id => 1,
                                               :project_id => 1,
                                               :email_body => content_for_tracker_2,
                                               :tracker_id => 2)
    end

    it "sends a notification depending on the issue tracker" do
      ActionMailer::Base.deliveries.clear

      assert_difference 'ActionMailer::Base.deliveries.size', 3 do
        assert_difference 'Issue.count' do
          post :create, params: { :project_id => 1,
                                  :issue => { :tracker_id => 1,
                                              :subject => 'This is the test_new issue',
                                              :description => 'This is the description',
                                              :priority_id => 5,
                                              :unregistered_watchers => ["some_provider@example.com"],
                                              :notif_sent_to_unreg_watchers => true,
                                              :custom_field_values => { '2' => 'Value for field 2' } } }
        end
      end

      expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

      unregistered_watchers_email = ActionMailer::Base.deliveries.first
      expect(unregistered_watchers_email[recipient_field].value).to include "some_provider@example.com"
      unregistered_watchers_email.parts.each do |part|
        expect(part.body.raw_source).to include content_for_tracker_1
      end
    end

    it "sends a different notification depending on the issue tracker" do
      ActionMailer::Base.deliveries.clear

      assert_difference 'ActionMailer::Base.deliveries.size', 3 do
        assert_difference 'Issue.count' do
          post :create, params: { :project_id => 1,
                                  :issue => { :tracker_id => 2,
                                              :subject => 'This is the test_new issue',
                                              :description => 'This is the description',
                                              :priority_id => 5,
                                              :unregistered_watchers => ["some_provider@example.com"],
                                              :notif_sent_to_unreg_watchers => true,
                                              :custom_field_values => { '2' => 'Value for field 2' } } }
        end
      end

      expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

      unregistered_watchers_email = ActionMailer::Base.deliveries.first
      expect(unregistered_watchers_email[recipient_field].value).to include "some_provider@example.com"
      unregistered_watchers_email.parts.each do |part|
        expect(part.body.raw_source).to include content_for_tracker_2
      end
    end

    it "sends a standard notification for trackers without specified message" do
      ActionMailer::Base.deliveries.clear
      Project.update({ :unreg_watchers_all_trackers => true })

      assert_difference 'ActionMailer::Base.deliveries.size', 3 do
        assert_difference 'Issue.count' do
          post :create, params: { :project_id => 1,
                                  :issue => { :tracker_id => 3,
                                              :subject => 'This is a new issue',
                                              :description => 'This is the description',
                                              :priority_id => 5,
                                              :unregistered_watchers => ["some_provider_03@example.com"],
                                              :notif_sent_to_unreg_watchers => true,
                                              :custom_field_values => { '2' => 'Value for field 2' } } }
        end
      end

      expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

      unregistered_watchers_email = ActionMailer::Base.deliveries.first
      expect(unregistered_watchers_email[recipient_field].value).to include "some_provider_03@example.com"
      unregistered_watchers_email.parts.each do |part|
        expect(part.body.raw_source).to include "Email body content for status 2"
      end
    end
  end

  it "creates a new issue with a single unregistered watcher (not an array)" do
    assert_difference 'Issue.count' do
      post :create, params: { :project_id => 1,
                              :issue => { :tracker_id => 3,
                                          :subject => 'This is the test_new issue',
                                          :description => 'This is the description',
                                          :priority_id => 5,
                                          :unregistered_watchers => "captain@example.com",
                                          :notif_sent_to_unreg_watchers => true,
                                          :custom_field_values => { '2' => 'Value for field 2' } } }
    end

    issue = Issue.last
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => issue.id)
    expect(issue.unregistered_watchers.map(&:email)).to include "captain@example.com"
  end

  it "creates a new issue with multiple unregistered watchers separated by commas (not an array)" do
    assert_difference 'Issue.count' do
      post :create, params: { :project_id => 1,
                              :issue => { :tracker_id => 3,
                                          :subject => 'This is the test_new issue',
                                          :description => 'This is the description',
                                          :priority_id => 5,
                                          :unregistered_watchers => "captain@example.com,boss@email.com,some_provider@example.com",
                                          :notif_sent_to_unreg_watchers => true,
                                          :custom_field_values => { '2' => 'Value for field 2' } } }
    end

    issue = Issue.last
    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => issue.id)
    expect(issue.unregistered_watchers.map(&:email).size).to eq 3
    expect(issue.unregistered_watchers.map(&:email)).to include "captain@example.com"
    expect(issue.unregistered_watchers.map(&:email)).to include "boss@email.com"
    expect(issue.unregistered_watchers.map(&:email)).to include "some_provider@example.com"
  end

end
