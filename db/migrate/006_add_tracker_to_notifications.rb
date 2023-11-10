class AddTrackerToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :unregistered_watchers_notifications, :tracker_id, :integer
    if index_exists?(:unregistered_watchers_notifications, [:issue_status_id, :project_id], unique: true, name: "index_unreg_watchers_on_issue_status_id_and_project_id")
      remove_index :unregistered_watchers_notifications, [:issue_status_id, :project_id], unique: true, name: "index_unreg_watchers_on_issue_status_id_and_project_id"
    end
    add_index :unregistered_watchers_notifications, [:issue_status_id, :project_id, :tracker_id], unique: true, name: "index_unreg_watchers_on_status_id_and_project_id"
  end
end
