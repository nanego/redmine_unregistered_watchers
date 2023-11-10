class AddTrackerToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :unregistered_watchers_notifications, :tracker_id, :integer
    remove_index :unregistered_watchers_notifications, name: "index_unreg_watchers_on_issue_status_id_and_project_id", if_exists: true
    add_index :unregistered_watchers_notifications, [:issue_status_id, :project_id, :tracker_id], unique: true, name: "index_unreg_watchers_on_status_id_and_project_id"
  end
end
