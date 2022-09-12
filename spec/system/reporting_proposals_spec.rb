# frozen_string_literal: true

require "spec_helper"

describe "Reporting proposals overrides", type: :system do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:user) { create(:user, :confirmed, organization: organization) }

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
  end

  shared_examples "4 steps" do
    it "sidebar has the complete step" do
      click_link "New proposal"

      expect(page).to have_content("Step 1 of 4")
      within ".wizard__steps" do
        expect(page).to have_content("Complete")
      end
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
