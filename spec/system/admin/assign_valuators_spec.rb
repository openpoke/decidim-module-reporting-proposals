# frozen_string_literal: true

require "spec_helper"
require "system/shared/admin_proposals_overdue_examples"

describe "Assign valuators" do
  let(:manifest_name) { "reporting_proposals" }
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, component:) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }
  let!(:valuator) { valuator_role.user }
  let!(:valuator_role) { logged_valuator_role }
  let!(:logged_valuator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:another_valuator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:logged_valuator_role) { create(:participatory_process_user_role, role: :valuator, user: logged_valuator, participatory_process:) }
  let!(:another_valuator_role) { create(:participatory_process_user_role, role: :valuator, user: another_valuator, participatory_process:) }
  let(:login_user) { user }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as login_user, scope: :user
    visit current_path
  end

  shared_examples "assigns a valuator" do
    it "assigns the proposals to the valuator" do
      click_on translated(proposal.title)
      within "#valuators" do
        expect(page).to have_no_content(valuator.name)
      end

      within "#js-form-assign-proposal-to-valuator" do
        select valuator.name, from: :assign_valuator_role_ids
      end

      click_on "Assign"

      expect(page).to have_content("Proposals assigned to a valuator successfully")

      within "#valuators" do
        expect(page).to have_content(valuator.name)
      end
    end
  end

  shared_examples "unassigns a valuator" do
    let!(:valuation_assignment) { create(:valuation_assignment, proposal:, valuator_role:) }

    it "unassigns the proposals from the valuator" do
      click_on translated(proposal.title)
      expect(page).to have_css("a.red-icon", count: 1)
      expect(page).to have_content(logged_valuator.name)
      expect(page).to have_content(another_valuator.name)

      accept_confirm do
        within "#valuators li", text: valuator.name do
          find("a.red-icon").click
        end
      end

      expect(page).to have_content("Valuator unassigned from proposals successfully")
    end
  end

  context "when admin assigns a validator" do
    it_behaves_like "assigns a valuator"
    it_behaves_like "unassigns a valuator"
  end

  context "when a valuator manages assignments" do
    let(:login_user) { logged_valuator }
    let(:valuator_role) { another_valuator_role }
    let!(:my_assignement) { create(:valuation_assignment, proposal:, valuator_role: logged_valuator_role) }

    before do
      switch_to_host(organization.host)
      login_as login_user, scope: :user
      sleep 0.5
      visit current_path
    end

    it_behaves_like "assigns a valuator"

    it "cannot unnassign other valuators" do
      create(:valuation_assignment, proposal:, valuator_role: another_valuator_role)
      click_on translated(proposal.title)
      within "#valuators li", text: logged_valuator.name do
        expect(page).to have_css("a.red-icon", count: 1)
      end
      within "#valuators li", text: another_valuator.name do
        expect(page).to have_no_css("a.red-icon", count: 1)
      end
    end

    context "when valuator is not assigned to the proposal" do
      let!(:another_proposal) { create(:proposal, component:) }

      it "has permission to access assigned" do
        visit Decidim::EngineRouter.admin_proxy(component).proposal_path(proposal)
        expect(page).to have_content(proposal.title["en"])
        expect(page).to have_no_content("You are not authorized to perform this action.")
      end

      it "has no permission to access" do
        visit Decidim::EngineRouter.admin_proxy(component).proposal_path(another_proposal)
        expect(page).to have_no_content(another_proposal.title["en"])
        expect(page).to have_content("You are not authorized to perform this action.")
      end
    end
  end

  context "when managing myself" do
    let(:login_user) { logged_valuator }
    let(:valuator_role) { logged_valuator_role }

    it_behaves_like "unassigns a valuator"
  end
end
