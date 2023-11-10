require 'mailer'
include UnregisteredWatchersHelper

module RedmineUnregisteredWatchers::MailerPatch

end

class Mailer < ActionMailer::Base

  def self.deliver_issue_to_unregistered_watchers(issue, notif)
    if Setting['plugin_redmine_unregistered_watchers']['watcher_custom_field_id'].present?
      custom_field = CustomField.find_by_id(Setting['plugin_redmine_unregistered_watchers']['watcher_custom_field_id'])
      to = issue.custom_field_value(custom_field)
    else
      to = issue.unregistered_watchers.map(&:email)
    end
    issue_to_unregistered_watchers(User.new, to, issue, notif).deliver_now
  end

  # Builds a mail to notify unregistered watchers about a new or an updated issue
  def issue_to_unregistered_watchers(empty_user, unregistered_watchers, issue, notif)
    unregistered_watchers = Array.wrap(unregistered_watchers) # ensure we get an array
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    @issue = issue
    @email_content = email_body_with_variables(issue, notif.email_body)
    subject = "[#{issue.project.name}] #{issue.subject}"
    mail :to => unregistered_watchers,
         :subject => subject do |format|
      format.text { render layout: 'mailer-unregistered-watchers' }
      format.html { render layout: 'mailer-unregistered-watchers' } unless Setting.plain_text_mail?
    end

    if unregistered_watchers.present?
      UnregisteredWatchersHistory.create(issue_status_id: notif.issue_status.id,
                                         issue_id: issue.id,
                                         content: @email_content,
                                         to: unregistered_watchers.join(', '),
                                         subject: subject)
    end

  end

  def self.resent_issue_to_unregistered_watchers(issue, previous_notification)
    resend_issue_to_unregistered_watchers(User.new, previous_notification.to, issue, previous_notification).deliver_now
  end

  # Builds a mail to resend a previous notification to unregistered watchers
  def resend_issue_to_unregistered_watchers(empty_user, unregistered_watchers, issue, previous_notification)
    unregistered_watchers = Array.wrap(unregistered_watchers) # ensure we get an array
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    @issue = issue
    @email_content = previous_notification.content
    subject = "[#{issue.project.name}] #{issue.subject}"

    mail :to => unregistered_watchers,
         :subject => subject do |format|
      format.text { render action: "issue_to_unregistered_watchers", layout: 'mailer-unregistered-watchers' }
      format.html { render action: "issue_to_unregistered_watchers", layout: 'mailer-unregistered-watchers' } unless Setting.plain_text_mail?
    end

  end
end
