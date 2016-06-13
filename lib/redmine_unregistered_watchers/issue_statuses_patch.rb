require_dependency 'issue_status'

class IssueStatus < ActiveRecord::Base
  has_many :unregistered_watchers_notifications
end
