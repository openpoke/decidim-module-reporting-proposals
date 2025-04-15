# frozen_string_literal: true

require "spec_helper"

describe "Assign valuators after update category" do # rubocop:disable RSpec/DescribeClass
  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:category) { create(:category, participatory_space: participatory_process) }
  let!(:category_new) { create(:category, participatory_space: participatory_process) }
  let!(:admin) { create(:user, :confirmed, :admin, organization:) }
  let!(:valuator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:valuator_role) { create(:participatory_process_user_role, role: :valuator, user: valuator, participatory_process:) }
  let!(:category_valuator) { create(:category_valuator, valuator_role:, category: category_new) }
  let!(:proposal) { create(:proposal, component:, category:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user

    visit manage_component_path(component)
  end

  context "when an admin updates the category of the proposal" do
    before do
      find_by_id("proposal_ids_s_").set(true)
      click_on "Actions"
      click_on "Change category"
      select category_new.name["en"], from: :category_id
      perform_enqueued_jobs { click_on "Update" }
    end

    it "has a valuator after updating" do
      click_on proposal.title["en"]

      expect(page).to have_content(valuator_role.user.name, count: 1)
    end
  end
end
