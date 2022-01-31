class UnregisteredWatchersNotification < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :issue_status
  belongs_to :tracker, optional: true

  safe_attributes :issue_status_id, :project_id, :email_body, :tracker_id

  validates_uniqueness_of :tracker_id, scope: [:issue_status, :project]

  validates_presence_of :issue_status, :project

end
