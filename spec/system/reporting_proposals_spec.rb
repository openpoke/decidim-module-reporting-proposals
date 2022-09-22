# frozen_string_literal: true

require "spec_helper"

describe "Reporting proposals overrides", type: :system do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) do
    create(:reporting_proposals_component,
           :with_extra_hashtags,
           participatory_space: participatory_process,
           suggested_hashtags: suggested_hashtags,
           automatic_hashtags: automatic_hashtags)
  end
  let(:automatic_hashtags) { "HashtagAuto1 HashtagAuto2" }
  let(:suggested_hashtags) { "HashtagSuggested1 HashtagSuggested2" }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:user_group) { create(:user_group, :verified, users: [user], organization: organization) }
  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }
  let(:proposal_category) { category }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let!(:another_category) { create :category, participatory_space: participatory_process }
  let(:address) { "Plaça Santa Jaume, 1, 08002 Barcelona" }
  let(:latitude) { 41.3825 }
  let(:longitude) { 2.1772 }

  before do
    stub_geocoding(address, [latitude, longitude])
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def fill_proposal(extra_fields: true, skip_address: false, skip_group: false)
    within ".card__content form" do
      fill_in :proposal_title, with: proposal_title
      fill_in :proposal_body, with: proposal_body
      if extra_fields
        select translated(proposal_category.name), from: :proposal_category_id
        fill_in :proposal_address, with: address
        check "#HashtagSuggested1"
        select user_group.name, from: :proposal_user_group_id unless skip_group
        check "proposal_has_no_address" if skip_address
      end
      find("*[type=submit]").click
    end
  end

  def complete_proposal
    within ".card__content form" do
      select translated(another_category.name), from: :proposal_category_id
      select user_group.name, from: :proposal_user_group_id
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
      body = translated(proposal.body)
      expect(body).to have_content(proposal_body)
      expect(proposal.category).to eq(category)
      expect(proposal.address).to eq(address)
      expect(proposal.latitude).to eq(latitude)
      expect(proposal.longitude).to eq(longitude)
      expect(body).to have_content("HashtagAuto1")
      expect(body).to have_content("HashtagAuto2")
      expect(body).to have_content("HashtagSuggested1")
      expect(body).not_to have_content("HashtagSuggested2")
      expect(proposal.identities.first).to eq(user_group)
      # expect(proposal.scope).to eq(scope)
    end

    it "modifies the proposal" do
      click_link "New proposal"

      fill_proposal

      click_link "Modify the proposal"

      complete_proposal

      click_button "Publish"

      expect(page).to have_content(proposal_title)
      expect(translated(proposal.body)).to have_content(proposal_body)
      expect(proposal.category).to eq(another_category)
    end

    it "stores no address if checked" do
      click_link "New proposal"

      fill_proposal(skip_address: true, skip_group: true)

      click_button "Publish"

      expect(page).to have_content("successfully published")

      expect(page).to have_content(proposal_title)
      expect(translated(proposal.body)).to have_content(proposal_body)
      expect(proposal.category).to eq(category)
      expect(proposal.identities.first).to eq(user)
      expect(proposal.address).to be_nil
      expect(proposal.latitude).to be_nil
      expect(proposal.longitude).to be_nil
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
      expect(proposal.identities.first).to eq(user)

      complete_proposal

      click_button "Publish"

      expect(page).to have_content(proposal_title)
      expect(translated(proposal.body)).to eq(proposal_body)
      expect(proposal.category).to eq(another_category)
      expect(proposal.identities.first).to eq(user_group)
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
