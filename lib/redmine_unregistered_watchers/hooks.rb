module RedmineUnregisteredWatchers
  class Hooks < Redmine::Hook::ViewListener

    # adds our css on each page
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("unregistered_watchers", :plugin => "redmine_unregistered_watchers")
    end
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'issue_patch'
      require_relative 'issue_statuses_patch'
      require_relative 'issue_query_patch'
      require_relative 'issues_helper_patch'
      require_relative 'issues_controller_patch'
      require_relative 'project_patch'
      require_relative 'projects_helper_patch'
      require_relative 'journal_patch'
      require_relative 'journals_helper_patch'
      require_relative 'mailer_patch'
      require_relative 'queries_helper_patch'
    end

  end
end
