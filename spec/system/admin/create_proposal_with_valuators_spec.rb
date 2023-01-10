# frozen_string_literal: true

require "spec_helper"

describe "Create proposal with valuators", type: :system do
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

  context "when an admin manages the component" do
    before do
      click_link("New proposal")

      fill_in("proposal_title_en", with: "Test title for proposal")
      find('.ql-editor').set('Test description for proposal')
      select category.name["en"], from: :proposal_category_id

      click_button "Create"
    end

    it "has a valuator after creating" do
      within(".valuators-count") do
        expect(page).to have_content("1")
      end
    end
  end
end
