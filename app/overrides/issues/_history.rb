Deface::Override.new :virtual_path  => 'issues/_history',
                     :name          => 'unregistered_watchers_notifs_are_not_editable',
                     :replace       => 'erb[loud]:contains("render_notes")',
                     :text          => <<EOS
<% if journal.id.present? %>
  <%= render_notes(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
<% else %>
  <%= render_read_only_mail_notification(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/_history',
                     :name          => 'unregistered_watchers_notifs_have_no_author',
                     :replace       => 'erb[loud]:contains("authoring journal.created_on")',
                     :text          => <<EOS
<% if journal.id.present? %>
  <%= authoring journal.created_on, journal.user, :label => :label_updated_time_by %>
<% else %>
  <%= "Mail envoyé au demandeur il y a "%>
  <%= time_tag(journal.created_on).html_safe %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/_history',
                     :name          => 'add-container-to-mail-notifications',
                     :surround      => "div:contains(id, 'change-')",
                     :text          => <<-EOS
<% if journal.id.nil? %>
  <div class='issue-mail-notification-container'>
  <%= render_original %>
  </div>
<% else %>
  <%= render_original %>
<% end %>
EOS

