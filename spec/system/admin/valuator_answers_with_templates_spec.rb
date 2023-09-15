# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/factories"

describe "Valuator answers with templates", type: :system do
  let(:organization) { create :organization }
  let(:user) { create :user, :confirmed, :admin_terms_accepted, organization: organization }
  let!(:valuator_role) { create :participatory_process_user_role, role: :valuator, user: user, participatory_process: participatory_process }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:proposal_component) { create :component, manifest_name: :proposals, participatory_space: participatory_process }
  let!(:reporting_component) { create :component, manifest_name: :reporting_proposals, settings: settings, default_step_settings: settings, participatory_space: participatory_process }
  let(:settings) do
    { proposal_answering_enabled: true }
  end
  let(:component) { reporting_component }
  let!(:template) { create(:template, :proposal_answer, description: { en: description }, field_values: values, organization: organization, templatable: reporting_component) }
  let!(:proposal) { create(:proposal, component: component) }
  let!(:valuation_assignment) { create(:valuation_assignment, proposal: proposal, valuator_role: valuator_role) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit Decidim::EngineRouter.admin_proxy(component).root_path
    find("a", class: "action-icon--show-proposal").click
  end

  describe "using a proposal_answer_template" do
    let(:description) { "Some meaningful answer" }
    let(:values) do
      { internal_state: "evaluating" }
    end

    it "uses the template" do
      within ".edit_proposal_answer" do
        select template.name["en"], from: :proposal_answer_template_chooser
        expect(page).to have_content(description)
        click_button "Answer"
      end

      expect(page).to have_admin_callout("Proposal successfully answered")

      within find("tr", text: proposal.title["en"]) do
        expect(page).to have_content("Evaluating")
      end
    end

    it "shows an error message if the template is removed" do
      within ".edit_proposal_answer" do
        template.destroy!
        select template.name["en"], from: :proposal_answer_template_chooser
        expect(page).not_to have_content(description)
        expect(page).to have_content("Couldn't find this template")
      end
    end
  end
end
