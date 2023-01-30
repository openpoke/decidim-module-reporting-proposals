# frozen_string_literal: true

require "spec_helper"

describe "Automatic assign valuators after create proposals", type: :system do
  let!(:organization) { create :organization }
  let!(:participatory_process) { create :participatory_process, organization: organization }
  let!(:component) { create :reporting_proposals_component, participatory_space: participatory_process }
  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:admin) { create(:user, :confirmed, :admin, organization: organization) }
  let!(:valuator) { create :user, :confirmed, organization: organization }
  let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: participatory_process }
  let!(:category_valuator) { create(:category_valuator, valuator_role: valuator_role, category: category) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit manage_component_path(component)
  end

  context "when an admin create the proposal" do
    it "has a valuator after creating" do
      click_link("New proposal")

      fill_in("proposal_title_en", with: "Test title for proposal")
      find(".ql-editor").set("Test description for proposal")
      select category.name["en"], from: :proposal_category_id

      perform_enqueued_jobs { click_button "Create" }

      within(".valuators-count") do
        expect(page).to have_content(valuator.name)
      end
    end
  end

  context "when a proposal was published in public side" do
    it "has a valuator after creating" do
      original_page = page.current_window
      new_window = window_opened_by { click_link "View public page" }

      switch_to_window new_window
      click_link component.name["en"]
      click_link "New proposal"
      select category.name["en"], from: :proposal_category_id
      check "Has no address"
      check "Has no image"
      fill_in("proposal_title", with: "Test title for proposal")
      fill_in("proposal_body", with: "Test description for proposal")
      click_button "Continue"

      perform_enqueued_jobs { click_button "Publish" }

      switch_to_window original_page
      click_link component.name["en"]

      within(".valuators-count") do
        expect(page).to have_content(valuator.name)
      end
    end
  end
end
