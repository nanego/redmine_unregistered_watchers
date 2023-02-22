require_dependency 'issues_controller'

class IssuesController < ApplicationController

  append_before_action :set_unregistered_watchers, :only => [:create, :update]
  skip_before_action :authorize, :only => [:resend_watchers_notification]

  def resend_watchers_notification
    if params[:issue_id].present? && params[:history_id].present?
      watchers_history = UnregisteredWatchersHistory.where(id: params[:history_id]).first

      issue = Issue.find(params[:issue_id])
      Mailer.deliver_issue_resend_to_unregistered_watchers(issue, watchers_history)
        new_journal = Journal.new(journalized_id: params[:history_id], journalized_type: 'UnregisteredWatchersHistory',
          user: User.current, :notes => watchers_history.content)

        # avoid to call  after_create_commit: send_notification
        Journal.skip_callback(:commit, :after, :send_notification)
        new_journal.save!
        
        Journal.set_callback(:commit, :after, :send_notification)
    end     
      
    redirect_to issue_path(params[:issue_id])
    
  end

  private

    def set_unregistered_watchers
      @unregistered_watchers = []
      if params[:issue] && params[:issue][:unregistered_watchers].present?
        Array.wrap(params[:issue][:unregistered_watchers]).reject(&:blank?).each do |emails|
          emails.split(',').each do |email|
            @unregistered_watchers << UnregisteredWatcher.new(email: email.strip)
          end
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
