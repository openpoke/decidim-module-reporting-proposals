# frozen_string_literal: true

require "spec_helper"

describe "Show evaluators name" do
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, component: proposal_component) }
  let!(:evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }
  let!(:evaluator2) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:evaluator_role2) { create(:participatory_process_user_role, role: :evaluator, user: evaluator2, participatory_process:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  it "shows the evaluator name in the list" do
    visit manage_component_path(proposal_component)
    expect(page).to have_no_content(evaluator.name)
    expect(page).to have_no_content("(+1)")
  end

  context "when one evaluator" do
    let!(:evaluation_assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }

    it "shows the evaluator name in the list" do
      visit manage_component_path(proposal_component)
      expect(page).to have_content(evaluator.name)
      expect(page).to have_no_content("(+1)")
    end

    context "and more than one evaluator" do
      let!(:evaluation_assignment2) { create(:evaluation_assignment, proposal:, evaluator_role: evaluator_role2) }

      it "shows the evaluator name in the list" do
        visit manage_component_path(proposal_component)
        expect(page).to have_content(evaluator.name)
        expect(page).to have_content("(+1)")
      end

      context "when the evaluator is removed and there's an orphan entry in the database" do
        before do
          evaluator_role.delete
        end

        it "shows the evaluator name in the list" do
          visit manage_component_path(proposal_component)
          expect(page).to have_no_content(evaluator.name)
          expect(page).to have_content("(+1)")
        end
      end
    end
  end
end
