class UnregisteredWatchersController < ApplicationController

  before_action :find_project, :only => [:update_status_notifications_per_project]
  before_action :require_admin, :only => [:settings]
  layout "admin"

  def update_status_notifications_per_project
    notifs = []
    if params[:notifications] && params[:notifications][:status_ids]
      params[:notifications][:status_ids].reject!(&:blank?)
      params[:notifications][:status_ids].each do |status_id|
        params[:notifications][:status][status_id].each do |tracker_id, message|
          notif_tracker_id = (tracker_id.to_i == 0 ? nil : tracker_id.to_i)
          notif = UnregisteredWatchersNotification.find_or_initialize_by(project: @project,
                                                                         issue_status_id: status_id,
                                                                         tracker_id: notif_tracker_id)

          notif.email_body = message
          notifs << notif
        end
      end
    end
    @project.unregistered_watchers_notifications = notifs
    @project.save
    redirect_to settings_project_path(@project, :tab => :unregistered_watchers)
  end

  def settings
    redirect_to plugin_settings_path 'redmine_unregistered_watchers'
  end

  private

  def find_project
    project_id = params[:notifications][:project_id]
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
