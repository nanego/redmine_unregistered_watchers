require "spec_helper"

describe "UnregisteredWatchersHelper" do
  include UnregisteredWatchersHelper

  fixtures :issues, :journals, :journal_details, :projects, :users, :enabled_modules, :enumerations,
           :trackers, :issue_statuses, :versions, :custom_fields, :custom_values, :custom_fields_projects,
           :custom_fields_trackers, :projects_trackers, :roles, :member_roles, :members

  let(:issue_1) { Issue.find(1) }

  describe "email body with variables" do

    it "returns the current description if it does not include variables" do
      description = "Cannot add articles to shopping cart"
      body = email_body_with_variables(issue_1, description)
      expect(body).to eq description
    end

    it "converts variables to strings in email body" do
      body = email_body_with_variables(issue_1, "Email content for issue #<<id>> : (<<status>>) <<subject>>")
      expect(body).to eq "Email content for issue #1 : (New) Cannot print recipes"
    end

    describe :issue_attributes do
      it "replaces tracker variable with current issue tracker" do
        body = "{tracker}: Cannot add articles to shopping cart"
        expect(email_body_with_variables(issue_1, body)).to eq "Bug: Cannot add articles to shopping cart"
      end

      it "replaces priority variable with current issue priority" do
        body = "Cannot add articles to shopping cart ({priority})"
        expect(email_body_with_variables(issue_1, body)).to eq "Cannot add articles to shopping cart (Low)"
      end

      it "can replace multiple variables" do
        body = "{tracker}: Cannot add articles to shopping cart ({priority})"
        expect(email_body_with_variables(issue_1, body)).to eq "Bug: Cannot add articles to shopping cart (Low)"
      end

      it "can include version and project" do
        body = "{tracker} {project} → {fixed_version}"
        issue_1.fixed_version_id = 3
        expect(email_body_with_variables(issue_1, body)).to eq "Bug eCookbook → 2.0"
      end
    end

    describe :last_note do
      it "can display the last note in email body" do
        body_with_last_note = email_body_with_variables(issue_1, "Last note: <<last_note>>")
        expect(body_with_last_note).to eq "Last note: Some notes with Redmine links: #2, r2."
      end

      it "does not display private notes" do
        Journal.create(journalized: issue_1, private_notes: true, notes: "This notes is private")
        expect(issue_1.last_notes).to eq "This notes is private"

        body_with_last_note = email_body_with_variables(issue_1, "Last public note: <<last_note>>")
        expect(body_with_last_note).to eq "Last public note: Some notes with Redmine links: #2, r2."
      end

      it "displays the last note using newest syntax" do
        body_with_last_note = email_body_with_variables(issue_1, "Last note: {last_note}")
        expect(body_with_last_note).to eq "Last note: Some notes with Redmine links: #2, r2."
      end
    end

    describe :custom_fields do
      it "replaces a custom field id" do
        body = "Cannot add article {cf_2} to shopping cart"
        expect(email_body_with_variables(issue_1, body)).to eq "Cannot add article 125 to shopping cart"
      end

      it "replaces a custom field name" do
        body = "Cannot add article {cf_searchable_field} to shopping cart"
        expect(email_body_with_variables(issue_1, body)).to eq "Cannot add article 125 to shopping cart"
      end

      it "replaces a custom field name without uppercase letters" do
        body = "Cannot add article {cf_Float_Field} to shopping cart"
        expect(email_body_with_variables(issue_1, body)).to eq "Cannot add article 2.1 to shopping cart"
      end
    end

    if Redmine::Plugin.installed?(:redmine_magic_link)

      let!(:magic_link_rule) { MagicLinkRule.create!(role_id: 1, enabled: true, enabled_for_unregistered_watchers: true) }

      describe :magic_link do
        it "replaces a magic link" do
          body = "Click on this link : {magic_link_#{magic_link_rule.id}}"
          expect(email_body_with_variables(issue_1, body)).to eq "Click on this link : http://test.host/issues/1?issue_key=#{issue_1.issue_magic_link_rules.last.magic_link_hash}"
        end
      end

    end

  end
end
