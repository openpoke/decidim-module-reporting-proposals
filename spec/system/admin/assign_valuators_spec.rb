# frozen_string_literal: true

require "spec_helper"
require "system/shared/admin_proposals_overdue_examples"

describe "Assign valuators", type: :system do
  let(:manifest_name) { "reporting_proposals" }
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:component) { create :reporting_proposals_component, participatory_space: participatory_process }
  let!(:proposal) { create :proposal, component: component }
  let!(:user) { create :user, :confirmed, :admin, organization: organization }
  let!(:valuator) { create :user, :confirmed, organization: organization }
  let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: participatory_process }

  include_context "when managing a component as an admin"

  context "when admin to assign a validator" do
    before do
      visit current_path

      click_link translated(proposal.title)

      within "#js-form-assign-proposal-to-valuator" do
        find("#valuator_role_id").click
        find("option", text: valuator.name).click
      end

      click_button "Assign"
    end

    it "assigns the proposals to the valuator" do
      expect(page).to have_content("Proposals assigned to a valuator successfully")

      within find("tr", text: translated(proposal.title)) do
        expect(page).to have_selector("td.valuators-count", text: 1)
      end
    end
  end

  context "when a valuator manages assignments" do
    let!(:second_valuator) { create :user, :confirmed, organization: organization }
    let!(:second_valuator_role) { create :participatory_process_user_role, role: :valuator, user: second_valuator, participatory_process: participatory_process }

    before do
      switch_to_host(organization.host)
      login_as valuator, scope: :user
      create :valuation_assignment, proposal: proposal, valuator_role: valuator_role

      visit current_path
      click_link translated(proposal.title)
    end

    context "when a valuator assigns other valuators" do
      before do
        within "#js-form-assign-proposal-to-valuator" do
          find("#valuator_role_id").click
          find("option", text: second_valuator.name).click
        end
      end

      it "assigns the proposals to the valuator" do
        click_button "Assign"

        expect(page).to have_content("Proposals assigned to a valuator successfully")

        within find("tr", text: translated(proposal.title)) do
          expect(page).to have_selector("td.valuators-count", text: 2)
        end
      end
    end

    it "can remove only himself from the evaluators" do
      accept_confirm do
        within find("#valuators li", text: valuator.name) do
          find("a.red-icon").click
        end
      end

      expect(page).to have_content("Valuator unassigned from proposals successfully")

      within find("#valuators") do
        expect(page).not_to have_selector(".red-icon")
      end
    end
  end
end
