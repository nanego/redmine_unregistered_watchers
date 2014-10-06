require_dependency 'issue'

class Issue
  has_many :unregistered_watchers
end
