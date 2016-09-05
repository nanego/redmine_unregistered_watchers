require_dependency 'issue_query'

class IssueQuery < Query

  self.available_columns << QueryColumn.new(:unregistered_watchers, groupable: false, :sortable => false)

  unless instance_methods.include?(:initialize_available_filters_with_unregistered_watchers)
    def initialize_available_filters_with_unregistered_watchers
      initialize_available_filters_without_unregistered_watchers
      values = UnregisteredWatcher.order('LOWER(email)').map(&:email).compact.uniq
      add_available_filter("unregistered_watchers", :type => :list_optional, :values => values)
    end
    alias_method_chain :initialize_available_filters, :unregistered_watchers
  end

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
