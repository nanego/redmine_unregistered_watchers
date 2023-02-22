class UnregisteredWatchersHistory < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :issue
  belongs_to :issue_status

  safe_attributes :issue_status_id, :issue_id, :content, :to, :subject

  scope :re_sent_watchers_notification_issue, lambda { |issue_id|  where(:issue_id => issue_id) }

end
