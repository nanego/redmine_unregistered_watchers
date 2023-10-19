require "spec_helper"

describe ProjectsController, :type => :controller do

  fixtures :unregistered_watchers, :unregistered_watchers_notifications,
           :users, :issues, :trackers, :projects

  before do
    @request.session[:user_id] = 1
  end
  describe "copy a project" do
    let(:source_project) { Project.find(2) }

    it "copy all unregistered_watchers" do
      id = 1
      2.times do |i|
        UnregisteredWatchersNotification.create(issue_status_id: id, project_id: source_project.id, email_body: "hello#{i}#{id}", tracker_id: nil)
        UnregisteredWatchersNotification.create(issue_status_id: id, project_id: source_project.id, email_body: "hello#{i}#{id}", tracker_id: 1)
        id = 2
      end

      source_project.unreg_watchers_tracker_ids = [1, nil]
      source_project.unreg_watchers_all_trackers = false;
      source_project.save

      post :copy, :params => {
        :id => source_project.id,
        :project => {
          :name => 'test project',
          :identifier => 'test-project'
        },
        :only => %w(unregistered_watchers)
      }
      new_pro = Project.last

      expect(new_pro.unregistered_watchers_notifications.count).to eq(4)
      expect(new_pro.unreg_watchers_tracker_ids).to eq([1, nil])
      expect(new_pro.unreg_watchers_all_trackers).to eq(false)
      expect(new_pro.unregistered_watchers_notifications.first.email_body).to eq('hello01')
      expect(new_pro.unregistered_watchers_notifications.last.email_body).to eq('hello12')

    end
  end
end
