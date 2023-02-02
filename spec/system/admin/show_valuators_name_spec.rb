# frozen_string_literal: true

require "spec_helper"

describe "Show valuators name", type: :system do
  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:proposal) { create :proposal, component: proposal_component }
  let!(:valuator) { create :user, :confirmed, organization: organization }
  let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: valuator, participatory_process: participatory_process }
  let!(:valuator2) { create :user, :confirmed, organization: organization }
  let!(:valuator_role2) { create :participatory_process_user_role, role: :valuator, user: valuator2, participatory_process: participatory_process }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  it "shows the valuator name in the list" do
    visit manage_component_path(proposal_component)
    expect(page).not_to have_content(valuator.name)
    expect(page).not_to have_content("(+1)")
  end

  context "when one valuator" do
    let!(:valuation_assignment) { create :valuation_assignment, proposal: proposal, valuator_role: valuator_role }

    it "shows the valuator name in the list" do
      visit manage_component_path(proposal_component)
      expect(page).to have_content(valuator.name)
      expect(page).not_to have_content("(+1)")
    end

    context "and more than one valuator" do
      let!(:valuation_assignment2) { create :valuation_assignment, proposal: proposal, valuator_role: valuator_role2 }

      it "shows the valuator name in the list" do
        visit manage_component_path(proposal_component)
        expect(page).to have_content(valuator.name)
        expect(page).to have_content("(+1)")
      end
    end
  end
end
