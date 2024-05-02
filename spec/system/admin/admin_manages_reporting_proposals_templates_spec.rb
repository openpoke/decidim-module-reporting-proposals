# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposal answer templates" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_process) { create(:participatory_process, title: { en: "A participatory process" }, organization:) }
  let!(:reporting_component) { create(:component, manifest_name: :reporting_proposals, name: { en: "A reporting component" }, participatory_space: participatory_process) }
  let!(:proposals_component) { create(:component, manifest_name: :proposals, name: { en: "A proposals component" }, participatory_space: participatory_process) }
  let!(:template) { create(:template, :proposal_answer, description: { en: description }, field_values:, organization:, templatable: component) }
  let(:component) { reporting_component }
  let!(:proposal) { create(:proposal, component:) }
  let(:description) { "Some meaningful answer" }
  let(:field_values) { { internal_state: "rejected" } }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "creating a proposal_answer_template" do
    before do
      visit decidim_admin_templates.proposal_answer_templates_path
      within ".layout-content" do
        click_on "New"
      end
    end

    shared_examples "creates a new template with scopes" do |scope_name|
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
          select scope_name, from: :proposal_answer_template_component_constraint

          page.find("*[type=submit]").click
        end

        expect(page).to have_admin_callout("successfully")
        expect(page).to have_current_path decidim_admin_templates.proposal_answer_templates_path
        within ".table-list" do
          expect(page).to have_i18n_content(scope_name)
          expect(page).to have_content("My template")
        end
      end
    end

    it_behaves_like "creates a new template with scopes", "Global (available everywhere)"
    it_behaves_like "creates a new template with scopes", "Participatory process: A participatory process > A proposals component"
    it_behaves_like "creates a new template with scopes", "Participatory process: A participatory process > A reporting component"
  end

  describe "using a reporting proposal_answer_template" do
    before do
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

    context "when there are no templates" do
      before do
        template.destroy!
        visit Decidim::EngineRouter.admin_proxy(component).root_path
        find("a", class: "action-icon--show-proposal").click
      end

      it "hides the template selector in the proposal answer page" do
        expect(page).to have_no_select(:proposal_answer_template_chooser)
      end
    end

    context "when displaying current component and organization templates" do
      let!(:other_component) { create(:component, manifest_name: :proposals, name: { en: "Another component" }, participatory_space: participatory_process) }
      let!(:other_component_template) { create(:template, :proposal_answer, description: { en: "Foo bar" }, field_values: { internal_state: "evaluating" }, organization:, templatable: other_component) }
      let!(:proposal) { create(:proposal, component:) }

      it "displays the global template in dropdown" do
        expect(page).to have_select(:proposal_answer_template_chooser, with_options: [translated(template.name)])
      end

      it "hides templates scoped for other components" do
        expect(proposal.reload.internal_state).to eq("not_answered")
        expect(page).to have_no_select(:proposal_answer_template_chooser, with_options: [translated(other_component_template.name)])
      end
    end
  end
end
