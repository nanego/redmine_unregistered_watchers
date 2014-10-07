require_dependency 'journal'

class Journal

  after_create :send_notification_to_unregistered_watchers

  def send_notification_to_unregistered_watchers
    updated_issue = self.journalized.reload
    if updated_issue.is_a?(Issue) && updated_issue.project.module_enabled?("unregistered_watchers") && updated_issue.unregistered_watchers.present?
      if new_status.present?
        issue_notif = self.issue.project.unregistered_watchers_notifications.where("issue_status_id = ?", new_status.id).first
        if issue_notif.present?
          Mailer.deliver_issue_to_unregistered_watchers(updated_issue, issue_notif)
        end
      end
    end
  end

end
