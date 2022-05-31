Deface::Override.new  :virtual_path  => "projects/copy",
                    :name          => "copy-projects-unregistered_watchers",
                    :insert_after  => ".block:contains('@source_project.wiki.nil?')",
                    :text          => <<EOS
  <label class="block"><%= check_box_tag 'only[]', 'unregistered_watchers', true, :id => nil %> <%= l(:field_unregistered_watchers) %> (<%= @source_project.unregistered_watchers_notifications.nil? ? 0 : @source_project.unregistered_watchers_notifications.count %>)</label>
EOS
