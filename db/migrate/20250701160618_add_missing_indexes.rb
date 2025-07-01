class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :unregistered_watchers, :issue_id, if_not_exists: true
    add_index :unregistered_watchers_histories, :issue_id, if_not_exists: true
    add_index :unregistered_watchers_histories, :issue_status_id, if_not_exists: true
    add_index :unregistered_watchers_notifications, :issue_status_id, if_not_exists: true
    add_index :unregistered_watchers_notifications, :tracker_id, if_not_exists: true
  end
end
