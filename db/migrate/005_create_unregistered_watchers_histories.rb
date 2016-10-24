class CreateUnregisteredWatchersHistories < ActiveRecord::Migration
  def self.up
    create_table :unregistered_watchers_histories do |t|
      t.references :issue_status
      t.references :issue
      t.text :content
      t.string :to
      t.string :subject
      t.timestamps(null: false)
    end unless ActiveRecord::Base.connection.table_exists? 'unregistered_watchers_histories'
  end

  def self.down
    drop_table :unregistered_watchers_histories
  end
end
