Deface::Override.new virtual_path: "issues/tabs/_history",
                     name: "add-container-to-mail-notifications",
                     surround: "div:contains(id, 'change-')",
                     text: <<~EOS
                       <% if journal.journalized_type.in? %(Issue Notification) %>
                         <%= render_original %>
                       <% else %>
                         <div class='issue-mail-notification-container' id='mail-notification-<%= journal.object_id %>'>
                           <%= render partial: 'issues/unregistered_watchers_journal_item', locals: { journal: journal, issue: issue } %>
                         </div>
                       <% end %>
EOS
