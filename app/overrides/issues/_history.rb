Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'unregistered_watchers_notifs_are_not_editable',
                     :replace       => 'erb[loud]:contains("render_notes")',
                     :text          => <<EOS
<% if journal.persisted? && journal.journalized_type != "UnregisteredWatchersHistory" %>
  <%= render_notes(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
<% else %>
  <%= render_read_only_mail_notification(issue, journal, :reply_links => reply_links) unless journal.notes.blank? %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'unregistered_watchers_notifs_has_no_actions',
                     :replace       => 'erb[loud]:contains("render_journal_actions")',
                     :text          => <<EOS
<% if journal.persisted? && journal.journalized_type != "UnregisteredWatchersHistory" %>
  <%= render_journal_actions(issue, journal, :reply_links => reply_links) %>
<% end %>
EOS

Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                     :name          => 'unregistered_watchers_notifs_have_no_author',
                     :replace       => 'erb[loud]:contains("authoring journal.created_on")',
                     :text          => <<EOS
<% if journal.persisted? && journal.journalized_type != "UnregisteredWatchersHistory" %>
  <%= authoring journal.created_on, journal.user, :label => :label_updated_time_by %>
<% else %>
  <% label = journal.persisted? ? l(:label_watchers_notifications_resent, user: link_to_user(journal.user) ).html_safe : l(:automatic_mail_sent_to_watchers) %>
  <%= label %>
  <%= time_tag(journal.created_on).html_safe %>
  <% mail_id = "journal-"+journal.object_id.to_s+"-notes" %>
  <% link_id = "link-to-mail-notification-"+journal.object_id.to_s %>
  <%= content_tag(:span) { ('(' + content_tag(:a, l(:label_see_the_content_of_the_email), :href => "#", id: link_id, :onclick => "toggle_mail_details(event, '"+mail_id+"','"+link_id+"')" ) + ')').html_safe } %>
  <% if User.current.allowed_to?(:resend_unregistered_watchers_notification, @project) &&  !journal.persisted? %><%= link_to l(:resend_this_mail), resend_watchers_notification_path(issue_id: @issue.id, history_id: journal.history_id), :method => :post, :class => "icon icon-notified" %><% end %>
<% end %> 
<script type="text/javascript">
  var toggle_mail_details = function(event, mail_id, link_id) {
    blockEventPropagation(event);
    $('#'+mail_id).toggleClass('hidden');
    if($('#'+mail_id).is(':visible')) {
      $('#'+link_id).text('<%= l(:label_hide_the_content_of_the_email) %>')
    }else{
      $('#'+link_id).text('<%= l(:label_see_the_content_of_the_email) %>')
    };
    return false;
  }
</script>
EOS

# add this condition ,to avoid the conflict with the plugin redmine_notified,it has the same override name add-container-to-mail-notifications.
# if it is installed,we need only wrapping the watchers_notifications_resent by div class(issue-mail-notification-container)
if Redmine::Plugin.installed?(:redmine_notified)
  Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                       :name          => 'add-container-to-resent-mail-watchers-notifications',
                       :original      => '68e145deae6a29591c73e2ca568cbac07e2fdbd0',
                       :surround      => "div:contains(id, 'change-')",
                       :text          => <<-EOS
<% if journal.persisted? && journal.journalized_type == "UnregisteredWatchersHistory" %> 
  <div class='issue-mail-notification-container' id='mail-notification-<%= journal.object_id %>'>
    <%= render_original %>
  </div>
<% else %>  
    <%= render_original %> 
<% end %> 
EOS
else
  Deface::Override.new :virtual_path  => 'issues/tabs/_history',
                       :name          => 'add-container-to-mail-notifications',
                       :original      => '68e145deae6a29591c73e2ca568cbac07e2fdbd0',
                       :surround      => "div:contains(id, 'change-')",
                       :text          => <<-EOS
  <% if journal.persisted? && journal.journalized_type != "UnregisteredWatchersHistory" %>
    <%= render_original %>
  <% else %> 
    <div class='issue-mail-notification-container' id='mail-notification-<%= journal.object_id %>'>
      <%= render_original %>
    </div>
  <% end %>
EOS
end
