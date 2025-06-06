# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/factories"

describe "Valuator answers with templates" do
  let!(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:valuator_role) { create(:participatory_process_user_role, role: :valuator, user:, participatory_process:) }
  let(:participatory_process) { create(:participatory_process, title: { en: "A participatory process" }, organization:) }
  let!(:reporting_component) { create(:component, manifest_name: :reporting_proposals, name: { en: "A reporting component" }, participatory_space: participatory_process) }
  let(:component) { reporting_component }
  let!(:proposal) { create(:proposal, component:) }
  let!(:valuation_assignment) { create(:valuation_assignment, proposal:, valuator_role:) }
  let!(:template) { create(:template, target: :proposal_answer, description: { en: description }, field_values:, organization:, templatable: component) }
  let(:description) { "Some meaningful answer" }
  let(:field_values) { { proposal_state_id: Decidim::Proposals::ProposalState.find_by(component:, token: "rejected").id } }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit Decidim::EngineRouter.admin_proxy(component).root_path
    find("a", class: "action-icon--show-proposal").click
  end

  it "uses the template" do
    expect(proposal.reload.internal_state).to eq("not_answered")
    within ".edit_proposal_answer" do
      select template.name["en"], from: :proposal_answer_template_chooser
      expect(page).to have_content(description)
      click_on "Answer"
    end

    expect(page).to have_admin_callout("Proposal successfully answered")

    within "tr", text: proposal.title["en"] do
      expect(page).to have_content("Rejected")
    end
    expect(proposal.reload.internal_state).to eq("rejected")
  end
end
