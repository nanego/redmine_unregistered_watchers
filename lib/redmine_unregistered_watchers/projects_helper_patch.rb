require_dependency 'projects_helper'

module PluginUnregisteredWatchers
  module ProjectsHelper
    def project_settings_tabs
      tabs = super
      if @project.module_enabled?("unregistered_watchers")
        unregistered_watchers_tab = {name: 'unregistered_watchers', action: :unregistered_watchers, partial: 'projects/unregistered_watchers', label: :project_module_unregistered_watchers}
        tabs << unregistered_watchers_tab
      end
      tabs
    end
  end
end

ProjectsHelper.prepend PluginUnregisteredWatchers::ProjectsHelper
ActionView::Base.send(:include, ProjectsHelper)
