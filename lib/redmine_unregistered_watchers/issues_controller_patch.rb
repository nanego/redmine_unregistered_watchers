require_dependency 'issues_controller'

class IssuesController

  append_before_filter :set_unregistered_watchers, :only => [:create, :update]

  private

    def set_unregistered_watchers
      @unregistered_watchers = []
      if params[:issue] && params[:issue][:unregistered_watchers]
        params[:issue][:unregistered_watchers].reject!(&:blank?)
        params[:issue][:unregistered_watchers].each do |email|
          @unregistered_watchers << UnregisteredWatcher.new(email: email)
        end
        # update_journal_with_unregistered_users unless @issue.new_record? # TODO
        @issue.unregistered_watchers = @unregistered_watchers
      end
    end

end
