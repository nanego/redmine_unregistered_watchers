Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'unregistered_watchers_notifs_are_not_editable',
                     :replace       => 'erb[loud]:contains("render_notes")',
                     :text          => <<EOS
<% if journal.persisted? %>
  <%= render_notes(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
<% else %>
  <%= render_read_only_mail_notification(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'unregistered_watchers_notifs_has_no_actions',
                     :replace       => 'erb[loud]:contains("render_journal_actions")',
                     :text          => <<EOS
<% if journal.persisted? %>
  <%= render_journal_actions(issue, journal, :reply_links => reply_links) %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'unregistered_watchers_notifs_have_no_author',
                     :replace       => 'erb[loud]:contains("authoring journal.created_on")',
                     :text          => <<EOS
<% if journal.persisted? %>
  <%= authoring journal.created_on, journal.user, :label => :label_updated_time_by %>
<% else %>
  <%= "Mail automatique envoyé au demandeur il y a "%>
  <%= time_tag(journal.created_on).html_safe %>
  <% mail_id = "journal-"+journal.object_id.to_s+"-notes" %>
  <% link_id = "link-to-mail-notification-"+journal.object_id.to_s %>
  <%= content_tag(:span) { ('(' + content_tag(:a, 'Voir le contenu du mail', :href => "#", id: link_id, :onclick => "toggle_mail_details(event, '"+mail_id+"','"+link_id+"')" ) + ')').html_safe } %>
<% end %>
<script type="text/javascript">
  var toggle_mail_details = function(event, mail_id, link_id) {
    blockEventPropagation(event);
    $('#'+mail_id).toggle();
    if($('#'+mail_id).is(':visible')) {
      $('#'+link_id).text('Masquer le contenu du mail')
    }else{
      $('#'+link_id).text('Voir le contenu du mail')
    };
    return false;
  }
</script>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'add-container-to-mail-notifications',
                     :original      => '68e145deae6a29591c73e2ca568cbac07e2fdbd0',
                     :surround      => "div:contains(id, 'change-')",
                     :text          => <<-EOS
<% if journal.persisted? %>
  <%= render_original %>
<% else %>
  <div class='issue-mail-notification-container' id='mail-notification-<%= journal.object_id %>'>
    <%= render_original %>
  </div>
<% end %>
EOS
