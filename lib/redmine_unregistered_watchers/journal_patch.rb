require_dependency 'journal'

class Journal < ActiveRecord::Base

  after_create :send_notification_to_unregistered_watchers

  def send_notification_to_unregistered_watchers
    updated_issue = self.journalized.reload
    if updated_issue.is_a?(Issue) && updated_issue.project.module_enabled?("unregistered_watchers")
      issue_notif = self.issue.project.unregistered_watchers_notifications.find_by_issue_status_id(self.issue.status_id)
      if issue_notif.present? && self.issue.notif_sent_to_unreg_watchers
        Mailer.deliver_issue_to_unregistered_watchers(updated_issue, issue_notif)
      end
    end
  end

end
