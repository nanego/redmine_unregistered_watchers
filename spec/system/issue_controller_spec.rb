require "spec_helper"
require "active_support/testing/assertions"

describe "issue/show", type: :system do
  include ActiveSupport::Testing::Assertions

  fixtures :projects, :users, :issues, :journals

  let!(:issue) { Issue.find(1) }
  let!(:user_jsmith) { User.find(2) }
  let!(:private_note_1) { Journal.create(notes: "Private note test_1",
                                     journalized: issue,
                                     user_id: 1,
                                     private_notes: true,
                                     created_on: "2023-08-25 13:47:29") }#1

  let!(:note_1) { Journal.create(notes: "Note test_1",
                                     journalized: issue,
                                     user_id: 1,
                                     private_notes: false,
                                     created_on: "2023-08-26 13:48:29") }#2

  let!(:history_1) { UnregisteredWatchersHistory.create(issue_status_id: 1,
                                         issue_id: 1,
                                         content: "the issue has been opened !",
                                         to: "captain@example.com",
                                         subject: "[project_test] Feature request",
                                         created_at: "2023-08-27 13:49:29") }

  let!(:private_note_2) { Journal.create(notes: "Private note test_2",
                                     journalized: issue,
                                     user_id: 1,
                                     private_notes: true,
                                     created_on: "2023-08-28 13:50:29") }#4

  let!(:note_2) { Journal.create(notes: "Note test_2",
                                     journalized: issue,
                                     user_id: 1,
                                     private_notes: false,
                                     created_on: "2023-08-29 13:51:29") }#5

  let!(:history_2) { UnregisteredWatchersHistory.create(issue_status_id: 3,
                                         issue_id: 1,
                                         content: "the issue has been closed !",
                                         to: "captain@example.com",
                                         subject: "[project_test] Feature request",
                                         created_at: "2023-08-30 13:55:29") }

  it "Should show correct note number in case of non-admin user does not have the permission view_private_notes" do
    log_user('dlopper', 'foo')
    visit '/issues/1'
    expect(page).not_to have_selector(".journal-link", text: "#1")
    expect(page).to have_selector(".journal-link", text: "#2")
    expect(page).not_to have_selector(".journal-link", text: "#3")
    expect(page).to have_selector(".journal-link", text: "#4")
    expect(page).to have_selector(".journal-link", text: "#")
  end

  it "Should show correct note number in case of non-admin user has the permission view_private_notes" do
    log_user('jsmith', 'jsmith')
    visit '/issues/1'
    expect(page).to have_selector(".journal-link", text: "#1")
    expect(page).to have_selector(".journal-link", text: "#2")
    expect(page).to have_selector(".journal-link", text: "#3")
    expect(page).to have_selector(".journal-link", text: "#4")
    expect(page).to have_selector(".journal-link", text: "#")
  end
end