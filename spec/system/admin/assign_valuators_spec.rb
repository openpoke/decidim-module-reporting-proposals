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
  let!(:valuator) { create :user, :confirmed, :admin_terms_accepted, organization: organization }
  let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: participatory_process }

  include_context "when managing a component as an admin"

  shared_examples "assigns a valuator" do
    it "assigns the proposals to the valuator" do
      within "#valuators" do
        expect(page).not_to have_content(valuator.name)
      end

      click_button "Assign"

      expect(page).to have_content("Proposals assigned to a valuator successfully")

      within "#valuators" do
        expect(page).to have_content(valuator.name)
      end
    end
  end

  context "when admin assigns a validator" do
    before do
      visit current_path

      click_link translated(proposal.title)

      within "#js-form-assign-proposal-to-valuator" do
        find("#valuator_role_id").click
        find("option", text: valuator.name).click
      end
    end

    it_behaves_like "assigns a valuator"
  end

  context "when a valuator manages assignments" do
    let!(:second_valuator) { create :user, :confirmed, :admin_terms_accepted, organization: organization }
    let!(:second_valuator_role) { create :participatory_process_user_role, role: :valuator, user: second_valuator, participatory_process: participatory_process }

    before do
      switch_to_host(organization.host)
      login_as second_valuator, scope: :user
      create :valuation_assignment, proposal: proposal, valuator_role: second_valuator_role

      visit current_path
      click_link translated(proposal.title)
    end

    context "when a valuator assigns other valuators" do
      before do
        within "#js-form-assign-proposal-to-valuator" do
          find("#valuator_role_id").click
          find("option", text: valuator.name).click
        end
      end

      it_behaves_like "assigns a valuator"
    end

    context "when valuator removes assigment" do
      before do
        create :valuation_assignment, proposal: proposal, valuator_role: valuator_role
      end

      it "can remove only himself from the evaluators" do
        expect(page).to have_css("a.red-icon", count: 1)
        expect(page).to have_content(valuator.name)
        expect(page).to have_content(second_valuator.name)

        accept_confirm do
          within find("#valuators li", text: second_valuator.name) do
            find("a.red-icon").click
          end
        end

        expect(page).to have_content("Valuator unassigned from proposals successfully")
      end
    end
  end
end
