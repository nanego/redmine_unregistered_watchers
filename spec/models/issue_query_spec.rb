require 'spec_helper'
require 'redmine_unregistered_watchers/issue_query_patch'

describe IssueQuery do
  describe 'filters and columns' do
    it 'has a new available column for unregistered watchers' do
      expect(IssueQuery.available_columns.find { |column| column.name == :unregistered_watchers }).to_not be_nil
    end

    it 'initialize an "unregistered_watchers" filter' do
      query = IssueQuery.new
      expect(query.available_filters).to include 'unregistered_watchers'
    end
  end
end
