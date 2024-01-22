require "spec_helper"

describe "IssuesHelperPatch" do
  include ApplicationHelper
  include IssuesHelper
  include CustomFieldsHelper
  include ERB::Util
  include ActionView::Helpers::TagHelper

  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :custom_fields,
           :attachments,
           :versions

  before do
    set_language_if_valid('en')
    User.current = nil
  end

  ### custom tests for 'unregistered_watchers' property

  it "should IssuesHelper#show_detail with no_html should show a changing unregistered watcher" do
    detail = JournalDetail.new(:property => 'unregistered_watchers', :old_value => nil, :value => 'captain@example.com', :prop_key => nil)
    expect(show_detail(detail, true)).to eq "captain@example.com"
  end

  it "should IssuesHelper#show_detail with no_html should show a deleted unregistered watcher" do
    detail = JournalDetail.new(:property => 'unregistered_watchers', :old_value => 'captain@example.com', :value => nil, :prop_key => nil)
    expect(show_detail(detail, true)).to eq "captain@example.com"
  end

  it "should IssuesHelper#show_detail with html should show a new unregistered watcher with HTML highlights" do
    detail = JournalDetail.new(:property => 'unregistered_watchers', :old_value => nil, :value => 'captain@example.com', :prop_key => nil)
    detail.id = 1
    result = show_detail(detail, false)
    expect(result).to include("1 unregistered watcher has been added (<span class=\"journal_details\" data-detail-id=\"1\">captain@example.com</span>)")
  end

  it "should IssuesHelper#show_detail with html should show a deleted unregistered watcher with HTML highlights" do
    detail = JournalDetail.new(:property => 'unregistered_watchers', :old_value => 'captain@example.com', :value => nil, :prop_key => nil)
    html = show_detail(detail, false)
    expect(html).to include("1 unregistered watcher has been removed (<del class=\"journal_details\">captain@example.com</del>)")
  end

  it "should IssuesHelper#show_detail with html should show all new unregistered watchers with HTML highlights" do
    detail = JournalDetail.new(:property => 'unregistered_watchers', :old_value => nil, :value => 'captain@example.com,moos@example.com', :prop_key => nil)
    detail.id = 1
    result = show_detail(detail, false)
    html = "2 unregistered watchers have been added (<span class=\"journal_details\" data-detail-id=\"1\">captain@example.com, moos@example.com</span>)"
    expect(result).to include(html)
  end

  it "should IssuesHelper#show_detail with html should show all deleted unregistered watchers with HTML highlights" do
    detail = JournalDetail.new(:property => 'unregistered_watchers', :old_value => 'captain@example.com,moos@example.com', :value => nil, :prop_key => nil)
    result = show_detail(detail, false)
    html = "2 unregistered watchers have been removed (<del class=\"journal_details\">captain@example.com, moos@example.com</del>)"
    expect(result).to include(html)
  end


  ### core tests for core properties ('attr', 'attachment' and 'cf')

  it "should IssuesHelper#show_detail with no_html should show a changing attribute" do
    detail = JournalDetail.new(:property => 'attr', :old_value => '40', :value => '100', :prop_key => 'done_ratio')
    expect(show_detail(detail, true)).to eq "% Done changed from 40 to 100"
  end

  it "should IssuesHelper#show_detail with no_html should show a new attribute" do
    detail = JournalDetail.new(:property => 'attr', :old_value => nil, :value => '100', :prop_key => 'done_ratio')
    expect(show_detail(detail, true)).to eq("% Done set to 100")
  end

  it "should IssuesHelper#show_detail with no_html should show a deleted attribute" do
    detail = JournalDetail.new(:property => 'attr', :old_value => '50', :value => nil, :prop_key => 'done_ratio')
    expect(show_detail(detail, true)).to eq "% Done deleted (50)"
  end

  it "should IssuesHelper#show_detail with html should show a changing attribute with HTML highlights" do
    detail = JournalDetail.new(:property => 'attr', :old_value => '40', :value => '100', :prop_key => 'done_ratio')
    html = show_detail(detail, false)

    expect(html).to include('<strong>% Done</strong>')
    expect(html).to include('<i>40</i>')
    expect(html).to include('<i>100</i>')
  end

  it "should IssuesHelper#show_detail with html should show a new attribute with HTML highlights" do
    detail = JournalDetail.new(:property => 'attr', :old_value => nil, :value => '100', :prop_key => 'done_ratio')
    html = show_detail(detail, false)

    expect(html).to include('<strong>% Done</strong>')
    expect(html).to include('<i>100</i>')
  end

  it "should IssuesHelper#show_detail with html should show a deleted attribute with HTML highlights" do
    detail = JournalDetail.new(:property => 'attr', :old_value => '50', :value => nil, :prop_key => 'done_ratio')
    html = show_detail(detail, false)

    expect(html).to include('<strong>% Done</strong>')
    expect(html).to include('<del><i>50</i></del>')
  end



  it "should IssuesHelper#show_detail with a start_date attribute should format the dates" do
    detail = JournalDetail.new(
        :property  => 'attr',
        :old_value => '2010-01-01',
        :value     => '2010-01-31',
        :prop_key  => 'start_date'
    )
    assert_match "01/31/2010", show_detail(detail, true)
    assert_match "01/01/2010", show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail with a due_date attribute should format the dates" do
    detail = JournalDetail.new(
        :property  => 'attr',
        :old_value => '2010-01-01',
        :value     => '2010-01-31',
        :prop_key  => 'due_date'
    )
    assert_match "01/31/2010", show_detail(detail, true)
    assert_match "01/01/2010", show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show old and new values with a project attribute" do
    User.current = User.find(2)
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'project_id', :old_value => 1, :value => 2)
    assert_match 'eCookbook', show_detail(detail, true)
    assert_match 'OnlineStore', show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show old and new values with a issue status attribute" do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'status_id', :old_value => 1, :value => 2)
    assert_match 'New', show_detail(detail, true)
    assert_match 'Assigned', show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show old and new values with a tracker attribute" do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'tracker_id', :old_value => 1, :value => 2)
    assert_match 'Bug', show_detail(detail, true)
    assert_match 'Feature request', show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show old and new values with a assigned to attribute" do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'assigned_to_id', :old_value => 1, :value => 2)
    assert_match 'Redmine Admin', show_detail(detail, true)
    assert_match 'John Smith', show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show old and new values with a priority attribute" do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'priority_id', :old_value => 4, :value => 5)
    assert_match 'Low', show_detail(detail, true)
    assert_match 'Normal', show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show old and new values with a category attribute" do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'category_id', :old_value => 1, :value => 2)
    assert_match 'Printing', show_detail(detail, true)
    assert_match 'Recipes', show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show old and new values with a fixed version attribute" do
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'fixed_version_id', :old_value => 1, :value => 2)
    assert_match '0.1', show_detail(detail, true)
    assert_match '1.0', show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show old and new values with a estimated hours attribute" do
    # Redmine 5 timespan_format by default is minutes
    default_format = Setting.timespan_format
    Setting.timespan_format = 'decimal'
    detail = JournalDetail.new(:property => 'attr', :prop_key => 'estimated_hours', :old_value => '5', :value => '6.3')
    assert_match '5.00', show_detail(detail, true)
    assert_match '6.30', show_detail(detail, true)
    Setting.timespan_format = default_format

  end

  it "should IssuesHelper#show_detail should show old and new values with a custom field" do
    detail = JournalDetail.new(:property => 'cf', :prop_key => '1', :old_value => 'MySQL', :value => 'PostgreSQL')
    expect(show_detail(detail, true)).to eq 'Database changed from MySQL to PostgreSQL'
  end

  it "should IssuesHelper#show_detail should show added file" do
    detail = JournalDetail.new(:property => 'attachment', :prop_key => '1', :old_value => nil, :value => 'error281.txt')
    assert_match 'error281.txt', show_detail(detail, true)
  end

  it "should IssuesHelper#show_detail should show removed file" do
    detail = JournalDetail.new(:property => 'attachment', :prop_key => '1', :old_value => 'error281.txt', :value => nil)
    assert_match 'error281.txt', show_detail(detail, true)
  end

  describe "issue_attribute_value" do

    it "displays the value as a string" do
      issue = Issue.find(1)
      expect(issue_attribute_value(issue, 'subject')).to eq "Cannot print recipes"
    end

    it "displays the value as a date" do
      issue = Issue.find(1)
      expect(format_date(issue.created_on)).to match /..\/..\/..../
      expect(issue_attribute_value(issue, 'created_on')).to_not eq issue.created_on.to_s
      expect(issue_attribute_value(issue, 'created_on')).to eq issue.created_on.strftime("%m/%d/%Y")
    end

  end

end
