require 'redmine'
require_dependency 'redmine_unregistered_watchers/hooks'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine_unregistered_watchers/issue_patch'
  require_dependency 'redmine_unregistered_watchers/issue_statuses_patch'
  require_dependency 'redmine_unregistered_watchers/issues_helper_patch'
  require_dependency 'redmine_unregistered_watchers/issues_controller_patch'
  require_dependency 'redmine_unregistered_watchers/project_patch'
  require_dependency 'redmine_unregistered_watchers/projects_helper_patch'
  require_dependency 'redmine_unregistered_watchers/journal_patch'
  require_dependency 'redmine_unregistered_watchers/mailer_patch'
end

Redmine::Plugin.register :redmine_unregistered_watchers do
  name 'Redmine Unregistered Watchers plugin'
  author 'Vincent ROBERT'
  author_url 'mailto:contact@vincent-robert.com'
  description 'This plugin for Redmine make it possible to notify unregistered users by email when particular events occur on issues.'
  version '0.0.1'
  url 'https://github.com/nanego/redmine_notify_unregistered_users'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.3' if Rails.env.test?
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  project_module :unregistered_watchers do
    permission :set_unregistered_watchers_to_issues, {  }
  end
  settings :default => { 'emails_footer_for_unregistered_watchers' => "",
                         'status' => []},
           :partial => 'settings/redmine_plugin_unregistered_watchers'
end
