require_dependency 'issues_controller'

class IssuesController < ApplicationController

  append_before_filter :set_unregistered_watchers, :only => [:create, :update]

  private

    def set_unregistered_watchers
      @unregistered_watchers = []
      if params[:issue] && params[:issue][:unregistered_watchers]
        params[:issue][:unregistered_watchers].reject!(&:blank?)
        params[:issue][:unregistered_watchers].each do |email|
          @unregistered_watchers << UnregisteredWatcher.new(email: email)
        end
        update_journal_with_unregistered_watchers unless @issue.new_record?
        @issue.unregistered_watchers = @unregistered_watchers
      end
    end

    def update_journal_with_unregistered_watchers
      @current_journal = @issue.init_journal(User.current)
      unregistered_watchers_before_change = @issue.unregistered_watchers.map(&:email)
      unregistered_watchers = @unregistered_watchers.map(&:email)
      # unregistered watchers removed
      @current_journal.details << JournalDetail.new(:property => 'unregistered_watchers',
                                                    :old_value => (unregistered_watchers_before_change - unregistered_watchers).reject(&:blank?).join(","),
                                                    :value => nil) if (unregistered_watchers_before_change - unregistered_watchers).present?
      # unregistered watchers added
      @current_journal.details << JournalDetail.new(:property => 'unregistered_watchers',
                                                    :old_value => nil,
                                                    :value => (unregistered_watchers - unregistered_watchers_before_change).reject(&:blank?).join(","))  if (unregistered_watchers - unregistered_watchers_before_change).present?
    end

end
