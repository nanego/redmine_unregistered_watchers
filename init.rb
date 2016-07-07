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
  version '1.0.0'
  url 'https://github.com/nanego/redmine_unregistered_watchers'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.3' if Rails.env.test?
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  requires_redmine_plugin :redmine_base_select2, :version_or_higher => '4.0.0'
  project_module :unregistered_watchers do
    permission :set_unregistered_watchers_to_issues, {  }
  end
  settings :default => { 'emails_signature_for_unregistered_watchers' => "",
                         'emails_footer_for_unregistered_watchers' => "",
                         'unregistered_watchers_label' => "Notifier d'autres personnes",
                         'status' => []
                       },
           :partial => 'settings/redmine_plugin_unregistered_watchers'
end
