RedmineApp::Application.routes.draw do
  put :update_status_notifications_per_project, to: "unregistered_watchers#update_status_notifications_per_project"
  get 'unregistered_watchers/settings', to: "unregistered_watchers#settings"
  resources :unregistered_watchers_histories, only: [:show, :index]
  post 'issues/:issue_id/:history_id/resend_unregistered_watchers_notification', to: 'issues#resend_unregistered_watchers_notification' , as: :resend_unregistered_watchers_notification
end
