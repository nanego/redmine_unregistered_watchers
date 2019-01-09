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
  <%= "Mail automatique envoyé au demandeur il y a "%>
  <%= time_tag(journal.created_on).html_safe %>
  <% mail_id = "journal-"+journal.object_id.to_s+"-notes" %>
  <% link_id = "link-to-mail-notification-"+journal.object_id.to_s %>
  <%= content_tag(:span, id: link_id) { ('(' + content_tag(:a, 'Voir le contenu du mail', :href => "#", :onclick => "$('#"+mail_id+"').show();$('#"+link_id+"').hide();return false;") + ')').html_safe } %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/_history',
                     :name          => 'add-container-to-mail-notifications',
                     :original      => '68e145deae6a29591c73e2ca568cbac07e2fdbd0',
                     :surround      => "div:contains(id, 'change-')",
                     :text          => <<-EOS
<% if journal.id.nil? %>
  <div class='issue-mail-notification-container' id='mail-notification-<%= journal.object_id %>'>
  <%= render_original %>
  </div>
<% else %>
  <%= render_original %>
<% end %>
EOS

