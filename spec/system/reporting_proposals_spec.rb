# frozen_string_literal: true

require "spec_helper"

describe "Reporting proposals overrides", type: :system do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }
  let(:proposal_category) { category }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let!(:another_category) { create :category, participatory_space: participatory_process }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def fill_proposal(extra_fields: true)
    within ".card__content form" do
      fill_in :proposal_title, with: proposal_title
      fill_in :proposal_body, with: proposal_body
      select translated(proposal_category.name), from: :proposal_category_id if extra_fields
      find("*[type=submit]").click
    end
  end

  def complete_proposal
    within ".card__content form" do
      select translated(another_category.name), from: :proposal_category_id
      find("*[type=submit]").click
    end
  end

  shared_examples "3 steps" do
    it "sidebar does not have the complete step" do
      click_link "New proposal"

      expect(page).to have_content("Step 1 of 3")
      within ".wizard__steps" do
        expect(page).not_to have_content("Complete")
      end
    end

    it "redirects to the publish step" do
      click_link "New proposal"

      fill_proposal

      expect(page).to have_content(proposal_title)
      expect(page).to have_content(user.name)
      expect(page).to have_content(proposal_body)
      expect(page).to have_content(translated(proposal_category.name))

      expect(page).to have_selector("button", text: "Publish")

      expect(page).to have_selector("a", text: "Modify the proposal")
    end

    it "publishes the proposal" do
      click_link "New proposal"

      fill_proposal

      click_button "Publish"

      expect(page).to have_content("successfully published")

      expect(page).to have_content(proposal_title)
      expect(translated(proposal.body)).to eq(proposal_body)
      expect(proposal.category).to eq(category)
      # expect(proposal.scope).to eq(scope)
    end

    it "modifies the proposal" do
      click_link "New proposal"

      fill_proposal

      click_link "Modify the proposal"

      complete_proposal

      click_button "Publish"

      expect(page).to have_content(proposal_title)
      expect(translated(proposal.body)).to eq(proposal_body)
      expect(proposal.category).to eq(another_category)
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

    it "redirects to the complete step" do
      click_link "New proposal"

      fill_proposal(extra_fields: false)

      within ".section-heading" do
        expect(page).to have_content("COMPLETE YOUR PROPOSAL")
      end

      expect(page).to have_css(".edit_proposal")
    end

    it "publishes the proposal" do
      click_link "New proposal"

      fill_proposal(extra_fields: false)

      complete_proposal

      click_button "Publish"

      expect(page).to have_content(proposal_title)
      expect(translated(proposal.body)).to eq(proposal_body)
      expect(proposal.category).to eq(another_category)
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
