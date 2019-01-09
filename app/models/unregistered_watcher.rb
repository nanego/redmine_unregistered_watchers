class UnregisteredWatcher < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :issue
  safe_attributes :email, :issue_id

  def to_s
    self.email
  end

end
