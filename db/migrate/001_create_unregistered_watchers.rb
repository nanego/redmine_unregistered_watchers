class CreateUnregisteredWatchers < ActiveRecord::Migration
  def self.up
    create_table :unregistered_watchers do |t|
      t.column :issue_id, :integer
      t.column :email, :string
      t.timestamps(null: false)
    end unless ActiveRecord::Base.connection.table_exists? 'unregistered_watchers'
  end

  def self.down
    drop_table :unregistered_watchers
  end
end
