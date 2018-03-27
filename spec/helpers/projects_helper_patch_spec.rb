require "spec_helper"

describe "ProjectsHelperPatch" do
  include RSpec::Rails::ControllerExampleGroup

  fixtures :projects, :enabled_modules

  render_views

  before do
    @controller = ProjectsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
    @request.session[:user_id] = 1 # admin
  end

  it "should display project_settings_tabs_with_unreg_watchers IF module is enabled" do
    Project.find(1).enable_module!("unregistered_watchers")
    get :settings, :id => 1
    assert_select "a[href='/projects/1/settings/unregistered_watchers']"
  end

  it "should NOT display project_settings_tabs_with_unreg_watchers IF module is disabled" do
    Project.find(1).disable_module!("unregistered_watchers")
    get :settings, :id => 1
    assert_select "a[href='/projects/1/settings/unregistered_watchers']", false
  end


end
