class UnregisteredWatchersHistory < ActiveRecord::Base
  belongs_to :issue
  belongs_to :issue_status
  attr_accessible :issue_status_id, :issue_id, :content, :to, :subject
end
