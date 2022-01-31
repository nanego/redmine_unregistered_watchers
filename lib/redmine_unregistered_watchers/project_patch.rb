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
    notif
  end

end
