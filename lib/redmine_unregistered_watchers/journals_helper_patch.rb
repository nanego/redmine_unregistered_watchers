require_dependency 'journals_helper'

module JournalsHelper
  def render_read_only_mail_notification(issue, journal, options={})
    content = ''
    links = []
    if !journal.notes.blank?
      links << link_to(l(:button_quote),
                       quoted_issue_path(issue, :journal_id => journal),
                       :remote => true,
                       :method => 'post',
                       :title => l(:button_quote),
                       :class => 'icon-only icon-comment'
      ) if options[:reply_links]
    end
    content << content_tag('div', links.join(' ').html_safe, :class => 'contextual') unless links.empty?
    content << content_tag('div', simple_format(journal.notes), :class => 'content')
    css_classes = "wiki unregistered_watchers_history"
    content_tag('div', content.html_safe, :id => "journal-#{journal.object_id}-notes", :class => css_classes, style: 'display:none;')
  end
end
