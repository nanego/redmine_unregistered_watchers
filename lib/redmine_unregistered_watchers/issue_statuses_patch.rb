require_dependency 'issue_status'

class IssueStatus
  has_many :unregistered_watchers_notifications
end
