require_dependency 'issue'

class Issue < ActiveRecord::Base

  unloadable # Send unloadable so it will not be unloaded in development

  has_many :unregistered_watchers

  attr_accessor :force_notification_to_watchers

  after_create :send_notification_to_unregistered_watchers

  def send_notification_to_unregistered_watchers
    if self.project.module_enabled?("unregistered_watchers")
      new_issue_notif = self.project.unregistered_watchers_notifications.where("issue_status_id = ?", IssueStatus.order("position").pluck(:id).first).first
      if new_issue_notif.present?
        Mailer.deliver_issue_to_unregistered_watchers(self, new_issue_notif)
      end
    end
  end

  def last_note
    self.journals.map(&:notes).reject(&:blank?).first
  end
end
