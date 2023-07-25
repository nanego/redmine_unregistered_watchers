# add this condition, to avoid code duplication
if !Redmine::Plugin.installed?(:redmine_notified)
  Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                       :name          => 'unregistered_watchers_notifs_are_not_editable',
                       :replace       => 'erb[loud]:contains("render_notes")',
                       :text          => <<-EOS
  <% if journal.journalized_type == "Issue" %>
    <%= render_notes(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
  <% else %>
    <% options = [:reply_links => reply_links] %>
    <%= send "render_UnregisteredWatchersHistory_in_issue_history" , issue, journal, *options unless journal.notes.blank? %>
  <% end %>
  EOS

  Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                       :name          => 'unregistered_watchers_notifs_has_no_actions',
                       :replace       => 'erb[loud]:contains("render_journal_actions")',
                       :text          => <<-EOS
  <% if journal.journalized_type == "Issue" %>
    <%= render_journal_actions(issue, journal, :reply_links => reply_links) %>
  <% end %>
  EOS

  Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                       :name          => 'add-container-to-mail-notifications',
                       :original      => '68e145deae6a29591c73e2ca568cbac07e2fdbd0',
                       :surround      => "div:contains(id, 'change-')",
                       :text          => <<-EOS
    <% if journal.journalized_type == "Issue" %>
      <%= render_original %>
    <% else %> 
      <div class='issue-mail-notification-container' id='mail-notification-<%= journal.object_id %>'>
        <%= render_original %>
      </div>
    <% end %>
  EOS

end

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'unregistered_watchers_notifs_have_no_author',
                     :replace       => 'erb[loud]:contains("authoring journal.created_on")',
                     :partial       => "issues/journal_authoring"

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'unregistered_watchers_notifs_contextual_actions',
                     :insert_top    => 'div.contextual',
                     :partial       => "issues/journal_contextual_actions"
