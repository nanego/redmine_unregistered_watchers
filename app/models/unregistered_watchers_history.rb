class UnregisteredWatchersHistory < ApplicationRecord
  include Redmine::SafeAttributes

  belongs_to :issue
  belongs_to :issue_status

  safe_attributes :issue_status_id, :issue_id, :content, :to, :subject

end
