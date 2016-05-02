require 'mailer'

class Mailer

  def self.deliver_issue_to_unregistered_watchers(issue, notif)
    if Setting['plugin_redmine_unregistered_watchers']['watcher_custom_field_id'].present?
      custom_field = CustomField.find_by_id(Setting['plugin_redmine_unregistered_watchers']['watcher_custom_field_id'])
      to = issue.custom_field_value(custom_field)
    else
      to = issue.unregistered_watchers.map(&:email)
    end
    Mailer.issue_to_unregistered_watchers(issue, to, notif).deliver
  end

  # Builds a mail for notifying unregistered watchers about a new or an updated issue
  def issue_to_unregistered_watchers(issue, unregistered_watchers, notif)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    @email_content = notif.email_body
    mail :to => unregistered_watchers,
         :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}" do |format|
      format.text { render layout: 'mailer-unregistered-watchers' }
      format.html { render layout: 'mailer-unregistered-watchers' } unless Setting.plain_text_mail?
    end
  end

end
