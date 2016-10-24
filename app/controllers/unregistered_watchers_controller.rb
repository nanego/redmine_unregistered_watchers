class UnregisteredWatchersController < ApplicationController

  before_filter :find_project, :only => [:update_status_notifications_per_project]
  before_filter :require_admin, :only => [:settings]
  layout "admin"

  def update_status_notifications_per_project
    @notifications = []
    if params[:notifications] && params[:notifications][:status_ids]
      params[:notifications][:status_ids].reject!(&:blank?)
      params[:notifications][:status_ids].each do |status_id|
        notif = UnregisteredWatchersNotification.new(issue_status_id: status_id)
        notif.email_body = params[:notifications][:emails][status_id]
        @notifications << notif
      end
    end
    @project.unregistered_watchers_notifications = @notifications
    redirect_to settings_project_path(@project, :tab => :unregistered_watchers)
  end

  def settings
  end

  private

    def find_project
      project_id = params[:notifications][:project_id]
      @project = Project.find(project_id)
    rescue ActiveRecord::RecordNotFound
      render_404
    end

end
