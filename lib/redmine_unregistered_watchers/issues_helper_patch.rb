require_dependency 'issues_helper'

module PluginUnregisteredWatchers
  module IssuesHelper

    # Returns the textual representation of a single journal detail
    # Core properties are 'attr', 'attachment' or 'cf' : this patch specify how to display 'unregistered_watchers' journal details
    # 'unregistered_watchers' property is introduced by this plugin
    def show_detail(detail, no_html = false, options = {})

      # Process custom 'unregistered_watchers' property
      if detail.property == 'unregistered_watchers'

        value = detail.value
        old_value = detail.old_value

        if value.present? # unregistered_watchers added to the issue

          value = value.split(',')
          list = content_tag("span", h(value.join(', ')), class: "journal_details", data: { detail_id: detail.id })

          if no_html
            value.join(', ')
          else
            details = "(#{list})"
            "#{value.size} #{value.size > 1 ? l(:text_journal_unregistered_watchers_added) : l(:text_journal_unregistered_watcher_added)} #{details}".html_safe
          end

        elsif old_value.present? # unregistered_watchers removed from the issue

          old_value = old_value.split(',')
          list = content_tag("del", h(old_value.join(', ')), class: "journal_details", data: { detail_id: detail.id })

          if no_html
            old_value.join(', ')
          else
            details = "(#{list})"
            "#{old_value.size} #{old_value.size > 1 ? l(:text_journal_unregistered_watchers_deleted) : l(:text_journal_unregistered_watcher_deleted)} #{details}".html_safe
          end

        end

      else
        # Process standard properties like 'attr', 'attachment' or 'cf'
        super
      end

    end

  end
end

IssuesHelper.prepend PluginUnregisteredWatchers::IssuesHelper
ActionView::Base.prepend IssuesHelper
