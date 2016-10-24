RedmineApp::Application.routes.draw do
  put :update_status_notifications_per_project, to: "unregistered_watchers#update_status_notifications_per_project"
  get 'unregistered_watchers/settings', to: "unregistered_watchers#settings"
  resources :unregistered_watchers_histories, only: [:show, :index]
end
