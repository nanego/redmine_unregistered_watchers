require "spec_helper"
require "active_support/testing/assertions"
require 'redmine_unregistered_watchers/issues_controller_patch.rb'
require 'redmine_unregistered_watchers/issue_patch.rb'

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
  end

  it "should send a notification to unregistered watchers after create" do
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.size', 3 do
      assert_difference 'Issue.count' do
        post :create, params: {:project_id => 1,
                               :issue => {:tracker_id => 3,
                                          :subject => 'This is the test_new issue',
                                          :description => 'This is the description',
                                          :priority_id => 5,
                                          :unregistered_watchers => ["captain@example.com",
                                                                     "boss@email.com",
                                                                     "some_provider@example.com"],
                                          :notif_sent_to_unreg_watchers => true,
                                          :custom_field_values => {'2' => 'Value for field 2'}}}
      end

    end

    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    expect(ActionMailer::Base.deliveries.size).to eq 3

    default_mail = ActionMailer::Base.deliveries.second
    expect(default_mail['bcc'].value).to include User.find(2).mail
    expect(default_mail['bcc'].value).to_not include "captain@example.com"
    expect(default_mail['bcc'].value).to_not include "boss@email.com"
    expect(default_mail['bcc'].value).to_not include "some_provider@example.com"
    default_mail.parts.each do |part|
      expect(part.body.raw_source).to include "has been reported by"
      expect(part.body.raw_source).to_not include "Email body content"
    end

    unregistered_watchers_email = ActionMailer::Base.deliveries.first
    expect(unregistered_watchers_email['bcc'].value).to_not include User.find(2).mail
    expect(unregistered_watchers_email['bcc'].value).to include "captain@example.com"
    expect(unregistered_watchers_email['bcc'].value).to include "boss@email.com"
    expect(unregistered_watchers_email['bcc'].value).to include "some_provider@example.com"
    unregistered_watchers_email.parts.each do |part|
      expect(part.body.raw_source).to_not include "has been reported by"
      expect(part.body.raw_source).to include "Email body content for status 2"
    end
  end

  it "should send a notification to unregistered watchers after create unless sent notif check box has been unchecked" do
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.size', 3 do
      assert_difference 'Issue.count' do
        post :create, params: {:project_id => 1,
                               :issue => {:tracker_id => 3,
                                          :subject => 'This is the test_new issue',
                                          :description => 'This is the description',
                                          :priority_id => 5,
                                          :estimated_hours => '',
                                          :unregistered_watchers => ["captain@example.com", "boss@email.com"],
                                          :notif_sent_to_unreg_watchers => false,
                                          :custom_field_values => {'2' => 'Value for field 2'}}}
      end
    end

    expect(response).to redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    expect(ActionMailer::Base.deliveries.size).to eq 3 # Only default notification to REGISTERED watchers
    default_mail = ActionMailer::Base.deliveries.second
    expect(default_mail['bcc'].value).to include(User.find(2).mail)
    expect(default_mail['bcc'].value).to_not include("captain@example.com")
    expect(default_mail['bcc'].value).to_not include("boss@email.com")
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
        put :update, params: {:id => 1, :issue => {:unregistered_watchers => ["captain@example.com", "another@email.com", "msjoe@example.com", "mrjohn@example.com"],
                                                   :notif_sent_to_unreg_watchers => true,
                                                   :status_id => '5' # close issue
        }}
      end
    end
    expect(ActionMailer::Base.deliveries.size).to eq 3

    default_mail = ActionMailer::Base.deliveries.second
    unregistered_watchers_email = ActionMailer::Base.deliveries.first

    expect(default_mail['bcc'].value).to include User.find(2).mail
    expect(default_mail['bcc'].value).to_not include "captain@example.com"
    expect(default_mail['bcc'].value).to_not include "boss@email.com"
    default_mail.parts.each do |part|
      expect(part.body.raw_source).to include "has been updated by"
      expect(part.body.raw_source).to_not include content
    end

    expect(unregistered_watchers_email['bcc'].value).to_not include User.find(2).mail
    expect(unregistered_watchers_email['bcc'].value).to include "captain@example.com"
    expect(unregistered_watchers_email['bcc'].value).to_not include "boss@email.com"
    unregistered_watchers_email.parts.each do |part|
      expect(part.body.raw_source).to_not include "has been updated by"
      expect(part.body.raw_source).to include content
    end
  end

  it "should send a notification to unregistered watchers after update and create journal details unless sent notif check box has been unchecked" do
    ActionMailer::Base.deliveries.clear

    content = "Custom body: the issue has been closed !"

    UnregisteredWatcher.create!(issue_id: 1, email: "captain@example.com")
    UnregisteredWatchersNotification.create!(:issue_status_id => 5, :project_id => 1, :email_body => content)

    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 3) do
        put :update, params: {:id => 1, :issue => {:unregistered_watchers => ["captain@example.com", "another@email.com"],
                                                   :notif_sent_to_unreg_watchers => false,
                                                   :status_id => '5' # close issue
        }}
      end
    end
    expect(ActionMailer::Base.deliveries.size).to eq 3 # Only default notification to REGISTERED watchers
    default_mails = ActionMailer::Base.deliveries.select { |mail|
      mail['subject'].value == "[eCookbook - Bug #1] (Closed) Cannot print recipes"
    }
    default_mails_recipients = default_mails.map { |m| m['bcc'].value }.flatten.uniq
    expect(default_mails_recipients).to include(User.find(2).mail)
    expect(default_mails_recipients).to_not include("captain@example.com")
    expect(default_mails_recipients).to_not include("boss@email.com")
    default_mails.first.parts.each do |part|
      expect(part.body.raw_source).to include "has been updated by"
      expect(part.body.raw_source).to_not include content
    end

  end

end
