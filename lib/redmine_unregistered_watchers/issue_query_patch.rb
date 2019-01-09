require_dependency 'issue_query'

module PluginUnregisteredWatchers
  module IssueQueryPatch
    def initialize_available_filters
      super
      values = UnregisteredWatcher.order(Arel.sql('LOWER(email)')).map(&:email).compact.uniq
      add_available_filter("unregistered_watchers", :type => :list_optional, :values => values)
    end
  end
end

class IssueQuery < Query
  prepend PluginUnregisteredWatchers::IssueQueryPatch

  self.available_columns << QueryColumn.new(:unregistered_watchers, groupable: false)

  def sql_for_unregistered_watchers_field(field, operator, value)
    case operator
      when "=", "!"
        db_table = UnregisteredWatcher.table_name
        "#{Issue.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } (SELECT #{db_table}.issue_id FROM #{db_table} WHERE " + sql_for_field(field, '=', value, db_table, 'email') + ')'
      when "*", "!*" # All / None
        db_table = UnregisteredWatcher.table_name
        "#{ operator == '*' ? 'EXISTS' : 'NOT EXISTS' } (SELECT #{db_table}.issue_id FROM #{db_table} WHERE #{Issue.table_name}.id = #{db_table}.issue_id )"
    end
  end

end
