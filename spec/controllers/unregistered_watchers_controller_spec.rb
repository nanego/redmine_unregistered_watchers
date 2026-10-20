require "spec_helper"

describe UnregisteredWatchersController, :type => :controller do
  fixtures :users, :projects, :trackers, :issue_statuses, :enabled_modules,
           :members, :roles, :member_roles

  let(:project) { Project.find(1) }
  let(:manager) { Role.find(1) } # jsmith (user 2) is manager of project 1

  let(:params) do
    { notifications: { project_id: project.id,
                       status_ids: ["1"],
                       status: { "1" => { "0" => "Message from the attacker" } } } }
  end

  before do
    project.enabled_module_names = project.enabled_module_names | ["unregistered_watchers"]
    project.unregistered_watchers_notifications.destroy_all
    @request.session[:user_id] = 2
  end

  it "updates the notifications when the user has the permission" do
    manager.add_permission!(:set_unregistered_watchers_to_issues)

    put :update_status_notifications_per_project, params: params

    expect(response).to redirect_to(settings_project_path(project, tab: :unregistered_watchers))
    expect(project.reload.unregistered_watchers_notifications.pluck(:email_body)).to eq(["Message from the attacker"])
  end

  it "denies the update without the permission" do
    manager.remove_permission!(:set_unregistered_watchers_to_issues)

    put :update_status_notifications_per_project, params: params

    expect(response).to have_http_status(403)
    expect(project.reload.unregistered_watchers_notifications).to be_empty
  end

  it "denies the update when the module is disabled" do
    manager.add_permission!(:set_unregistered_watchers_to_issues)
    project.enabled_module_names = project.enabled_module_names - ["unregistered_watchers"]

    put :update_status_notifications_per_project, params: params

    expect(response).to have_http_status(403)
    expect(project.reload.unregistered_watchers_notifications).to be_empty
  end

  it "returns a 404 without a project" do
    put :update_status_notifications_per_project, params: {}

    expect(response).to have_http_status(404)
  end
end
