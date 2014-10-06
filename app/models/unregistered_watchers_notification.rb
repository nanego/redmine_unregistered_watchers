class UnregisteredWatchersNotification < ActiveRecord::Base
  belongs_to :project
  belongs_to :issue_status
end
