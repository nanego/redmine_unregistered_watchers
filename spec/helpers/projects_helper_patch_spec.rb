require "spec_helper"

describe "ProjectsHelperPatch", type: :controller do

  fixtures :projects, :enabled_modules

  render_views

  before do
    @controller = ProjectsController.new
    @request    = ActionDispatch::TestRequest.create
    @response   = ActionDispatch::TestResponse.new
    User.current = nil
    @request.session = ActionController::TestSession.new
    @request.session[:user_id] = 1 # admin
  end

  it "should display project_settings_tabs_with_unreg_watchers IF module is enabled" do
    Project.find(1).enable_module!("unregistered_watchers")
    get :settings, params: {:id => 1}
    assert_select "a[href='/projects/1/settings/unregistered_watchers']"
  end

  it "should NOT display project_settings_tabs_with_unreg_watchers IF module is disabled" do
    Project.find(1).disable_module!("unregistered_watchers")
    get :settings, params: {:id => 1}
    assert_select "a[href='/projects/1/settings/unregistered_watchers']", false
  end

  it "should NOT display project_settings_tabs_with_unreg_watchers IF module is enabled and user does not have the permission" do
      @request.session[:user_id] = 3
      User.current = User.find(3)
      Project.find(1).enable_module!("unregistered_watchers")
      get :settings, params: { :id => 1 }
      assert_select "a[href='/projects/1/settings/unregistered_watchers']", false
  end

  it "should display project_settings_tabs_with_unreg_watchers IF module is enabled and user has the permission" do
      Project.find(1).enable_module!("unregistered_watchers")
      get :settings, params: { :id => 1 }
      assert_select "a[href='/projects/1/settings/unregistered_watchers']"
  end
end
