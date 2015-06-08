class UnregisteredWatcher < ActiveRecord::Base
  belongs_to :issue
  attr_accessible :email, :issue_id
end
