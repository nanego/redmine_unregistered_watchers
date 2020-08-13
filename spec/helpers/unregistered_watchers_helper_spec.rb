require "spec_helper"

describe "UnregisteredWatchersHelper" do
  include UnregisteredWatchersHelper

  fixtures :issues

  let(:issue_1) { Issue.find(1) }
  let(:email_body) { "Email content for issue #<<id>> : (<<status>>) <<subject>>" }

  it "converts variables to strings in email body" do
    body = email_body_with_variables(issue_1, email_body)
    expect(body).to eq "Email content for issue #1 : (New) Cannot print recipes"
  end
end
