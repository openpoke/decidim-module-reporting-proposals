# frozen_string_literal: true

require "spec_helper"
require "decidim/templates/test/factories"

describe "Admin manages proposal answer templates" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:proposal_component) { create(:component, manifest_name: :proposals, participatory_space: participatory_process) }
  let!(:reporting_component) { create(:component, manifest_name: :reporting_proposals, settings:, default_step_settings: settings, participatory_space: participatory_process) }
  let(:settings) do
    { proposal_answering_enabled: true }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "listing templates" do
    let!(:template1) { create(:template, :proposal_answer, organization:, templatable: proposal_component) }
    let!(:template2) { create(:template, :proposal_answer, organization:, templatable: reporting_component) }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
    end

    it "shows a table with the templates info" do
      within ".questionnaire-templates" do
        expect(page).to have_i18n_content(template1.name)
        expect(page).to have_i18n_content(template2.name)
        expect(page).to have_i18n_content("Participatory process: #{participatory_process.title["en"]} > #{proposal_component.name["en"]}")
        expect(page).to have_i18n_content("Participatory process: #{participatory_process.title["en"]} > #{reporting_component.name["en"]}")
      end
    end
  end

  describe "creating a proposal_answer_template" do
    let(:scope_name) { "Participatory process: #{participatory_process.title["en"]} > #{reporting_component.name["en"]}" }

    before do
      visit decidim_admin_templates.proposal_answer_templates_path
      within ".layout-content" do
        click_link_or_button("New")
      end
    end

    it "creates a new template" do
      within ".new_proposal_answer_template" do
        fill_in_i18n(
          :proposal_answer_template_name,
          "#proposal_answer_template-name-tabs",
          en: "My template",
          es: "Mi plantilla",
          ca: "La meva plantilla"
        )
        fill_in_i18n_editor(
          :proposal_answer_template_description,
          "#proposal_answer_template-description-tabs",
          en: "Description",
          es: "Descripción",
          ca: "Descripció"
        )

        choose "Not answered"
        select scope_name, from: :proposal_answer_template_scope_for_availability

        page.find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).to have_current_path decidim_admin_templates.proposal_answer_templates_path
      within ".questionnaire-templates" do
        expect(page).to have_i18n_content(scope_name)
        expect(page).to have_content("My template")
      end
    end
  end

  describe "using a proposal_answer_template" do
    let(:description) { "Some meaningful answer" }
    let(:values) do
      { internal_state: "evaluating" }
    end
    let!(:template) { create(:template, :proposal_answer, description: { en: description }, field_values: values, organization:, templatable: reporting_component) }
    let!(:proposal) { create(:proposal, component: reporting_component) }

    before do
      visit Decidim::EngineRouter.admin_proxy(reporting_component).root_path
      find("a", class: "action-icon--show-proposal").click
    end

    it "uses the template" do
      within ".edit_proposal_answer" do
        select template.name["en"], from: :proposal_answer_template_chooser
        expect(page).to have_content(description)
        click_link_or_button "Answer"
      end

      expect(page).to have_admin_callout("Proposal successfully answered")

      within "tr", text: proposal.title["en"] do
        expect(page).to have_content("Evaluating")
      end
    end

    it "shows an error message if the template is removed" do
      within ".edit_proposal_answer" do
        template.destroy!
        select template.name["en"], from: :proposal_answer_template_chooser
        expect(page).to have_no_content(description)
        expect(page).to have_content("Couldn't find this template")
      end
    end
  end
end
