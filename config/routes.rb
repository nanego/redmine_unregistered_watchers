RedmineApp::Application.routes.draw do
  put :update_status_notifications_per_project, to: "unregistered_watchers#update_status_notifications_per_project"
end
