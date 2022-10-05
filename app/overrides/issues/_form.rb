Deface::Override.new :virtual_path  => "issues/_form",
                     :name          => "add-unregistered-watchers-to-issue-form",
                     :insert_bottom => '#attributes',
                     :partial       => "issues/add_unregistered_watchers_to_issue"
Deface::Override.new :virtual_path  => "issues/_form_with_positions",
                     :name          => "add-unregistered-watchers-to-issue-form",
                     :insert_bottom => '#attributes',
                     :partial       => "issues/add_unregistered_watchers_to_issue"

Deface::Override.new :virtual_path  => "issues/_form",
                     :name          => "add-force-email-to-unregistered-watchers-checkbox-to-issue-form",
                     :insert_bottom => '#attributes',
                     :partial       => "issues/add_force_email_checkbox_to_form"
Deface::Override.new :virtual_path  => "issues/_form_with_positions",
                     :name          => "add-force-email-to-unregistered-watchers-checkbox-to-issue-form",
                     :insert_bottom => '#attributes',
                     :partial       => "issues/add_force_email_checkbox_to_form"
