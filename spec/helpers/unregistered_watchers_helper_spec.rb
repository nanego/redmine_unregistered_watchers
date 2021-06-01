require "spec_helper"

describe "UnregisteredWatchersHelper" do
  include UnregisteredWatchersHelper

  fixtures :issues, :journals, :journal_details

  let(:issue_1) { Issue.find(1) }
  let(:email_body) { "Email content for issue #<<id>> : (<<status>>) <<subject>>" }

  it "converts variables to strings in email body" do
    body = email_body_with_variables(issue_1, email_body)
    expect(body).to eq "Email content for issue #1 : (New) Cannot print recipes"
  end

  it "can display the last note in email body" do
    body_with_last_note = email_body_with_variables(issue_1, "Last note: <<last_note>>")
    expect(body_with_last_note).to eq "Last note: Some notes with Redmine links: #2, r2."
  end
end
