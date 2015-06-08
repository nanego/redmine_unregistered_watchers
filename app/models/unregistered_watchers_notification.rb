class UnregisteredWatchersNotification < ActiveRecord::Base
  belongs_to :project
  belongs_to :issue_status
  attr_accessible :issue_status_id, :project_id, :email_body
end
