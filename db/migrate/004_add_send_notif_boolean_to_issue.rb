class AddSendNotifBooleanToIssue < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :notif_sent_to_unreg_watchers, :boolean
  end
end
