require_dependency 'issue'

class Issue < ActiveRecord::Base

  include Redmine::SafeAttributes

  has_many :unregistered_watchers
  has_many :unregistered_watchers_histories

  safe_attributes 'notif_sent_to_unreg_watchers'

  after_create :send_notification_to_unregistered_watchers

  # Add missing useful method (should be in Redmine core)
  def visible_custom_fields(user=nil)
    user_real = user || User.current
    available_custom_fields.select do |custom_field|
      custom_field.visible_by?(project, user_real)
    end
  end

  def send_notification_to_unregistered_watchers
    if self.project.module_enabled?("unregistered_watchers")
      new_issue_notif = self.project.unreg_watchers_notif_for(status_id: status_id, tracker_id: tracker_id)
      if notify_unreg_watchers?(new_issue_notif)
        Mailer.deliver_issue_to_unregistered_watchers(self, new_issue_notif)
      end
    end
  end

  def last_note
    last_public_notes
  end

  def last_public_notes
    journals.where.not(notes: '').where(private_notes: false).reorder(:id => :desc).first.try(:notes)
  end

  def notify_unreg_watchers?(message)
    return false unless message.present?
    return false if (Setting['plugin_redmine_unregistered_watchers']['allow_force_email_sending']=='true' && !notif_sent_to_unreg_watchers)
    # Do not send message if the exact same has already been sent
    last_notif = self.unregistered_watchers_histories.last
    if last_notif.present? && last_notif.content == Mailer.email_body_with_variables(self, message.email_body)
      return false
    else
      return true
    end

  end
end
