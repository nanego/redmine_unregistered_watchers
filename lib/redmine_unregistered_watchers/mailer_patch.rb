require 'mailer'

class Mailer

  def self.deliver_issue_to_unregistered_watchers(issue, notif)
    to = issue.unregistered_watchers.map(&:email)
    Mailer.issue_to_unregistered_watchers(issue, to, notif).deliver
  end

  # Builds a mail for notifying unregistered watchers about a new or an updated issue
  def issue_to_unregistered_watchers(issue, unregistered_watchers, notif)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login
    @email_content = notif.email_body
    mail :to => unregistered_watchers,
         :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
  end

end
