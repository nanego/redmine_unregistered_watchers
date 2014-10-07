require "spec_helper"
require "active_support/testing/assertions"
require 'redmine_unregistered_watchers/issues_controller_patch.rb'
require 'redmine_unregistered_watchers/issue_patch.rb'

describe IssuesController do
  render_views
  include ActiveSupport::Testing::Assertions

  fixtures :projects,
           :users,
           :roles,
           :members,
           :member_roles,
           :issue_statuses

  it "should send a notification to unregistered watchers after create" do
    ActionMailer::Base.deliveries.clear
    @request.session[:user_id] = 2

    EnabledModule.create!(:project_id => 1, :name => "unregistered_watchers")
    UnregisteredWatchersNotification.create!(:issue_status_id => 1, :project_id => 1, :email_body => "Email body content")

    assert_difference 'Issue.count' do
      post :create, :project_id => 1,
           :issue => {:tracker_id => 3,
                      :subject => 'This is the test_new issue',
                      :description => 'This is the description',
                      :priority_id => 5,
                      :estimated_hours => '',
                      :unregistered_watchers => ["captain@example.com", "boss@email.com"],
                      :custom_field_values => {'2' => 'Value for field 2'}}
    end
    response.should redirect_to(:controller => 'issues', :action => 'show', :id => Issue.last.id)

    ActionMailer::Base.deliveries.size.should == 2

    default_mail = ActionMailer::Base.deliveries.first
    assert default_mail['bcc'].to_s.include?(User.find(2).mail)
    assert !default_mail['bcc'].to_s.include?("captain@example.com")
    assert !default_mail['bcc'].to_s.include?("boss@email.com")
    default_mail.parts.each do |part|
      assert part.body.raw_source.should include "has been reported by"
      assert !(part.body.raw_source.should_not include "Email body content")
    end

    unregistered_watchers_email = ActionMailer::Base.deliveries.second
    assert !unregistered_watchers_email['bcc'].to_s.include?(User.find(2).mail)
    assert unregistered_watchers_email['bcc'].to_s.include?("captain@example.com")
    assert unregistered_watchers_email['bcc'].to_s.include?("boss@email.com")
    unregistered_watchers_email.parts.each do |part|
      assert !(part.body.raw_source.should_not include "has been reported by")
      assert part.body.raw_source.should include "Email body content"
    end
  end

  it "should send a notification to unregistered watchers after update ad create journal details" do
    @request.session[:user_id] = 2
    ActionMailer::Base.deliveries.clear

    issue = Issue.find(1)
    content = "Custom body: the issue has been closed !"

    EnabledModule.create!(:project_id => 1, :name => "unregistered_watchers")
    UnregisteredWatcher.create!(issue_id: 1, email: "captain@example.com")
    UnregisteredWatchersNotification.create!(:issue_status_id => 5, :project_id => 1, :email_body => content)

    old_subject = issue.subject
    new_subject = 'Subject modified by IssuesControllerTest#test_post_edit'
    assert_difference 'Journal.count' do
      assert_difference('JournalDetail.count', 2) do
        put :update, :id => 1, :issue => {:unregistered_watchers => ["captain@example.com", "another@email.com"],
                                          :status_id => '5' # close issue
        }
      end
    end
    ActionMailer::Base.deliveries.size.should == 2

    default_mail = ActionMailer::Base.deliveries.first
    assert default_mail['bcc'].to_s.include?(User.find(2).mail)
    assert !default_mail['bcc'].to_s.include?("captain@example.com")
    assert !default_mail['bcc'].to_s.include?("boss@email.com")
    default_mail.parts.each do |part|
      assert part.body.raw_source.should include "has been updated by"
      assert !(part.body.raw_source.should_not include content)
    end

    unregistered_watchers_email = ActionMailer::Base.deliveries.second
    assert !unregistered_watchers_email['bcc'].to_s.include?(User.find(2).mail)
    assert unregistered_watchers_email['bcc'].to_s.include?("captain@example.com")
    assert !unregistered_watchers_email['bcc'].to_s.include?("boss@email.com")
    unregistered_watchers_email.parts.each do |part|
      assert !(part.body.raw_source.should_not include "has been updated by")
      assert part.body.raw_source.should include content
    end
  end

end
