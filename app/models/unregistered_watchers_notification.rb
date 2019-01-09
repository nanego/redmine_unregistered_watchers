class UnregisteredWatchersNotification < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :issue_status

  safe_attributes :issue_status_id, :project_id, :email_body
end
