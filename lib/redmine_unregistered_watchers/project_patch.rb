require_dependency 'project'

class Project < ActiveRecord::Base
  has_many :unregistered_watchers_notifications
end
