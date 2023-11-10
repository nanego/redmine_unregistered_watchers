require_dependency 'queries_helper'

module RedmineUnregisteredWatchers
  module QueriesHelperPatch

    def column_value(column, issue, values)
      if column.name == :unregistered_watchers && values.kind_of?(ActiveRecord::Associations::CollectionProxy)
        values.to_a.map(&:email).compact.uniq.join(", ")
      else
        super
      end
    end

  end
end

QueriesHelper.include IssuesHelper
QueriesHelper.prepend RedmineUnregisteredWatchers::QueriesHelperPatch
ActionView::Base.prepend QueriesHelper
IssuesController.prepend QueriesHelper
