class AddTrackersSettingsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :unreg_watchers_all_trackers, :boolean, default: true
    add_column :projects, :unreg_watchers_tracker_ids, :integer, array: true, default: []
  end
end
