Deface::Override.new :virtual_path  => "issues/_form",
                     :name          => "add-unregistered-watchers-to-issue-form",
                     :insert_after  => "div#attributes",
                     :partial       => "issues/add_unregistered_watchers_to_issue"
