Deface::Override.new :virtual_path => 'issues/show',
                     :original     => 'ee65ebb813ba3bbf55bc8dc6279f431dbb405c48',
                     :name         => 'show-unregistered-watchers-in-issue-description',
                     :insert_after => '.attributes',
                     :partial         => 'issues/show_watchers'

Deface::Override.new :virtual_path  => 'issues/show',
                     :name          => 'add-unregistered-watchers-histories-to-journals',
                     :insert_before => 'h2',
                     :text          => <<EOS
<%
  @issue.unregistered_watchers_histories.each do |mail|
    @journals << Journal.new(:journalized => @issue, 
                             :user => nil, 
                             :notes => mail.content, 
                             :recipients => mail.to,
                             :private_notes => false, 
                             :created_on => mail.created_at)
  end
  @journals.sort_by!(&:created_on)
  @journals.each_with_index {|j, i| j.indice = i + 1}
  @journals.reverse! if User.current.wants_comments_in_reverse_order?
%>
EOS
