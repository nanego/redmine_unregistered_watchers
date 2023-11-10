module RedmineUnregisteredWatchers::IssueStatusesPatch

  def self.included(base)
    # :nodoc:
    base.class_eval do
      has_many :unregistered_watchers_notifications
    end
  end
end

IssueStatus.send(:include, RedmineUnregisteredWatchers::IssueStatusesPatch)
