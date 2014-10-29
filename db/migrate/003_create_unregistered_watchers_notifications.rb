class CreateUnregisteredWatchersNotifications < ActiveRecord::Migration
  def self.up
    create_table :unregistered_watchers_notifications do |t|
      t.references :issue_status
      t.references :project
      t.text :email_body
    end unless ActiveRecord::Base.connection.table_exists? 'unregistered_watchers_notifications'
    add_index :unregistered_watchers_notifications, :project_id
    add_index :unregistered_watchers_notifications, [:issue_status_id, :project_id], :unique => true, name: "index_unreg_watchers_on_issue_status_id_and_project_id"
  end

  def self.down
    drop_table :unregistered_watchers_notifications
  end
end
