require_dependency 'journal'

class Journal

  attr_accessor :recipients
  attr_accessor :history_id

  after_create_commit :send_notification_to_unregistered_watchers

  def send_notification_to_unregistered_watchers
    if self.journalized.is_a?(Issue) && self.journalized.project.module_enabled?("unregistered_watchers")
      updated_issue = self.journalized.reload
      issue_notif = updated_issue.project.unreg_watchers_notif_for(status_id: updated_issue.status_id, tracker_id: updated_issue.tracker_id)
      if updated_issue.notify_unreg_watchers?(issue_notif)
        Mailer.deliver_issue_to_unregistered_watchers(updated_issue, issue_notif)
      end
    end
  end

  def is_a_resent_notification?
    self.persisted? && self.journalized.is_a?(UnregisteredWatchersHistory)
  end

end

module RedmineUnregisteredWatchers
  module JournalPatch
    # Patch to avoid overriding journalized_attribute_names and to avoid using acts_as_customizable
    def start
      if journalized_type == "UnregisteredWatchersHistory"
        self
      else
        super
      end
    end
  end
end
Journal.prepend RedmineUnregisteredWatchers::JournalPatch
