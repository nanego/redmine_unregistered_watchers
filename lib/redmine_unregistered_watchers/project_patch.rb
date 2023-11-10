require_dependency 'project'

class Project < ActiveRecord::Base
  has_many :unregistered_watchers_notifications, dependent: :destroy

  safe_attributes :unreg_watchers_all_trackers, :unreg_watchers_tracker_ids

  def unreg_watchers_notif_for(status_id:, tracker_id:)
    if unreg_watchers_all_trackers
      notif = unregistered_watchers_notifications.find_by(issue_status_id: status_id, tracker_id: nil)
    else
      notif = unregistered_watchers_notifications.find_by(issue_status_id: status_id, tracker_id: tracker_id)
      if notif.blank?
        notif = unregistered_watchers_notifications.find_by(issue_status_id: status_id, tracker_id: nil)
      end
    end
    if notif.present? && notif.email_body.present?
      notif
    else
      nil
    end
  end

end

module RedmineUnregisteredWatchers
  module ProjectPatch
    # Copies unregistered_watchers_notifications from +project+
    def copy_unregistered_watchers(project)
      project.unregistered_watchers_notifications.each do |notif|
        new_notif = UnregisteredWatchersNotification.new
        new_notif.attributes =
          notif.attributes.dup.except("id", "project_id")
        new_notif.project = self
        self.unregistered_watchers_notifications << new_notif
      end
      self.unreg_watchers_tracker_ids = project.unreg_watchers_tracker_ids
      self.unreg_watchers_all_trackers = project.unreg_watchers_all_trackers
    end

    def copy(project, options={})
      super
      project = project.is_a?(Project) ? project : Project.find(project)

      to_be_copied = %w(unregistered_watchers)

      to_be_copied = to_be_copied & Array.wrap(options[:only]) unless options[:only].nil?

      Project.transaction do
        if save
          reload

          to_be_copied.each do |name|
            send "copy_#{name}", project
          end

          save
        else
          false
        end
      end
    end
  end
end

Project.prepend RedmineUnregisteredWatchers::ProjectPatch
