class AddUniqueIndex < ActiveRecord::Migration
  def change
    add_index :unregistered_watchers, [:issue_id, :email], :unique => true
  end
end
