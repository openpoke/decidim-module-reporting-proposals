# frozen_string_literal: true

require "spec_helper"

describe "Automatic assign valuators after create proposals" do
  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:admin) { create(:user, :confirmed, :admin, organization:) }
  let!(:valuator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:valuator_role) { create(:participatory_process_user_role, role: :valuator, user: valuator, participatory_process:) }
  let!(:category_valuator) { create(:category_valuator, valuator_role:, category:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  def public_component_path
    Decidim::EngineRouter.main_proxy(component).proposals_path
  end

  context "when an admin create the proposal" do
    it "has a valuator after creating" do
      visit manage_component_path(component)
      click_on("New proposal")

      fill_in_i18n :proposal_title, "#proposal-title-tabs", en: "Test title for proposal"
      fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", en: "Test description for proposal"

      select category.name["en"], from: :proposal_category_id

      perform_enqueued_jobs { click_on "Create" }

      within(".valuators-count") do
        expect(page).to have_content(valuator.name)
      end
    end
  end

  context "when a proposal was published in public side" do
    it "has a valuator after creating" do
      visit public_component_path

      click_on "New proposal"
      select category.name["en"], from: :proposal_category_id
      check "Has no address"
      check "Has no image"
      fill_in("proposal_title", with: "Test title for proposal")
      fill_in("proposal_body", with: "Test description for proposal")
      click_on "Continue"

      perform_enqueued_jobs { click_on "Publish" }

      visit manage_component_path(component)
      click_on component.name["en"]

      within(".valuators-count") do
        expect(page).to have_content(valuator.name)
      end
    end
  end
end
