# frozen_string_literal: true

require "spec_helper"

describe "Reporting proposals overrides", type: :system do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "3 steps" do
    it "sidebar does not have the complete step" do
      click_link "New proposal"

      expect(page).to have_content("Step 1 of 3")
      within ".wizard__steps" do
        expect(page).not_to have_content("Complete")
      end
    end

    it "redirects to the plublish action" do
      click_link "New proposal"

      within ".card__content form" do
        fill_in :proposal_title, with: proposal_title
        fill_in :proposal_body, with: proposal_body
        find("*[type=submit]").click
      end

      expect(page).to have_content(proposal_title)
      expect(page).to have_content(user.name)
      expect(page).to have_content(proposal_body)

      expect(page).to have_selector("button", text: "Publish")

      expect(page).to have_selector("a", text: "Modify the proposal")
    end
  end

  shared_examples "4 steps" do
    it "sidebar has the complete step" do
      click_link "New proposal"

      expect(page).to have_content("Step 1 of 4")
      within ".wizard__steps" do
        expect(page).to have_content("Complete")
      end
    end

    it "redirects to the complete action" do
      click_link "New proposal"

      within ".card__content form" do
        fill_in :proposal_title, with: proposal_title
        fill_in :proposal_body, with: proposal_body
        find("*[type=submit]").click
      end

      within ".section-heading" do
        expect(page).to have_content("COMPLETE YOUR PROPOSAL")
      end

      expect(page).to have_css(".edit_proposal")
    end
  end

  context "when creating a new proposal" do
    before do
      visit_component
    end

    it_behaves_like "3 steps"
  end

  context "and component is a normal proposal" do
    let(:manifest_name) { "proposals" }
    let!(:component) { create(:proposal_component, :with_creation_enabled, participatory_space: participatory_process) }

    before do
      visit_component
    end

    it_behaves_like "4 steps"
  end
end
