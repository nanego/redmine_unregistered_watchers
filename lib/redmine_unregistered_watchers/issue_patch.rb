require_dependency 'issue'

class Issue
  has_many :unregistered_watchers

  after_create :send_notification_to_unregistered_watchers

  def send_notification_to_unregistered_watchers
    if self.project.module_enabled?("unregistered_watchers")
      new_issue_notif = self.project.unregistered_watchers_notifications.where("issue_status_id = ?", IssueStatus.order("position").pluck(:id).first).first
      if new_issue_notif.present?
        Mailer.deliver_issue_to_unregistered_watchers(self, new_issue_notif)
      end
    end
  end
end
