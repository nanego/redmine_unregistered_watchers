require_dependency 'queries_helper'

module QueriesHelper
  include IssuesHelper

  unless instance_methods.include?(:column_value_with_unregistered_watchers)
    def column_value_with_unregistered_watchers(column, issue, values)
      if column.name == :unregistered_watchers && values.kind_of?(ActiveRecord::Associations::CollectionProxy)
        values.to_a.map(&:email).compact.uniq.join(", ")
      else
        column_value_without_unregistered_watchers(column, issue, values)
      end
    end
    alias_method_chain :column_value, :unregistered_watchers
  end

end
