Deface::Override.new :virtual_path => 'issues/show',
                     :name         => 'show-unregistered-watchers-in-issue-description',
                     :insert_after => '.attributes',
                     :partial         => 'issues/show_watchers'

Deface::Override.new :virtual_path  => 'issues/show',
                     :name          => 'add-unregistered-watchers-histories-to-journals',
                     :insert_before => 'h2',
                     :text          => <<EOS
<%
  @issue.unregistered_watchers_histories.each do |mail|
    @journals << Journal.new(:journalized => mail, 
                             :user => nil, 
                             :notes => mail.content, 
                             :recipients => mail.to,
                             :history_id => mail.id,
                             :private_notes => false, 
                             :created_on => mail.created_at)
  end
  @journals = @journals + Journal.where(journalized: UnregisteredWatchersHistory.where(issue_id: @issue.id))
  @journals.sort_by!(&:created_on)
  @journals.reverse! if User.current.wants_comments_in_reverse_order?
%>
EOS
