# frozen_string_literal: true

require "spec_helper"
require "system/shared/admin_proposals_overdue_examples"

describe "Assign evaluators" do
  let(:manifest_name) { "reporting_proposals" }
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, component:) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }
  let!(:evaluator) { evaluator_role.user }
  let!(:evaluator_role) { logged_evaluator_role }
  let!(:logged_evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:another_evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:logged_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: logged_evaluator, participatory_process:) }
  let!(:another_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: another_evaluator, participatory_process:) }
  let(:login_user) { user }

  include_context "when managing a component as an admin"

  before do
    switch_to_host(organization.host)
    login_as login_user, scope: :user
    visit current_path
  end

  shared_examples "assigns a evaluator" do
    it "assigns the proposals to the evaluator" do
      within "tr", text: translated(proposal.title) do
        find("button[data-controller='dropdown']").click
        click_on "Answer proposal"
      end
      within "#evaluators" do
        expect(page).to have_no_content(evaluator.name)
      end

      within "#js-form-assign-proposal-to-evaluator" do
        select evaluator.name, from: :assign_evaluator_role_ids
      end

      click_on "Assign"

      expect(page).to have_content("Proposals assigned to a evaluator successfully")
      within "#evaluators" do
        expect(page).to have_content(evaluator.name)
      end
    end
  end

  shared_examples "removes a evaluator" do
    let!(:evaluation_assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }

    it "removes the proposals from the evaluator" do
      within "tr", text: translated(proposal.title) do
        find("button[data-controller='dropdown']").click
        click_on "Answer proposal"
      end
      expect(page).to have_css("a.red-icon", count: 1)
      expect(page).to have_content(logged_evaluator.name)
      expect(page).to have_content(another_evaluator.name)

      accept_confirm do
        within "#evaluators li", text: evaluator.name do
          find("a.red-icon").click
        end
      end

      expect(page).to have_content("Evaluator unassigned from proposals successfully")
    end
  end

  context "when admin assigns a evaluator" do
    it_behaves_like "assigns a evaluator"
    it_behaves_like "removes a evaluator"
  end

  context "when a evaluator manages assignments" do
    let(:login_user) { logged_evaluator }
    let(:evaluator_role) { another_evaluator_role }
    let!(:my_assignement) { create(:evaluation_assignment, proposal:, evaluator_role: logged_evaluator_role) }

    before do
      relogin_as login_user, scope: :user
      visit current_path
    end

    it_behaves_like "assigns a evaluator"
    it "cannot unassign other evaluators" do
      create(:evaluation_assignment, proposal:, evaluator_role: another_evaluator_role)
      within "tr", text: translated(proposal.title) do
        find("button[data-controller='dropdown']").click
        click_on "Answer proposal"
      end
      within "#evaluators li", text: logged_evaluator.name do
        expect(page).to have_css("a.red-icon", count: 1)
      end
      within "#evaluators li", text: another_evaluator.name do
        expect(page).to have_no_css("a.red-icon", count: 1)
      end
    end

    context "when evaluator is not assigned to the proposal" do
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
    let(:login_user) { logged_evaluator }
    let(:evaluator_role) { logged_evaluator_role }

    it_behaves_like "removes a evaluator"
  end
end
