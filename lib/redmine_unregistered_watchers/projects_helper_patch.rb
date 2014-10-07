require_dependency 'projects_helper'

module ProjectsHelper

  unless instance_methods.include?(:project_settings_tabs_with_unregistered_watchers)
    def project_settings_tabs_with_unregistered_watchers
      tabs = project_settings_tabs_without_unregistered_watchers
      if @project.module_enabled?("unregistered_watchers")
        unregistered_watchers_tab = {name: 'unregistered_watchers', action: :unregistered_watchers, partial: 'projects/unregistered_watchers', label: :project_module_unregistered_watchers}
        tabs << unregistered_watchers_tab
      end
      tabs
    end
    alias_method_chain :project_settings_tabs, :unregistered_watchers
  end

end
