require_dependency 'journal'

class Journal < ActiveRecord::Base

  attr_accessor :recipients

  after_create_commit :send_notification_to_unregistered_watchers

  def send_notification_to_unregistered_watchers
    updated_issue = self.journalized.reload
    if updated_issue.is_a?(Issue) && updated_issue.project.module_enabled?("unregistered_watchers")
      issue_notif = updated_issue.project.unregistered_watchers_notifications.find_by_issue_status_id(updated_issue.status_id)
      if updated_issue.notify_unreg_watchers?(issue_notif)
        Mailer.deliver_issue_to_unregistered_watchers(updated_issue, issue_notif)
      end
    end
  end

end
