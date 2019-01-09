class AddUniqueIndex < ActiveRecord::Migration[4.2]
  def change
    add_index :unregistered_watchers, [:issue_id, :email], :unique => true unless index_exists?(:unregistered_watchers, [:issue_id, :email], :unique => true)
  end
end
