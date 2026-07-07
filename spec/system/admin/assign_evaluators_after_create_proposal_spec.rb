# frozen_string_literal: true

require "spec_helper"

describe "Automatic assign evaluators after create proposals" do
  let!(:organization) { create(:organization) }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process, settings: { taxonomy_filters: [taxonomy_filter.id] }) }
  let!(:admin) { create(:user, :confirmed, :admin, organization:) }
  let!(:evaluator) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }
  let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  def public_component_path
    Decidim::EngineRouter.main_proxy(component).proposals_path
  end

  context "when an admin create the proposal" do
    it "has a evaluator after creating" do
      visit manage_component_path(component)
      click_on("New proposal")

      fill_in_i18n :proposal_title, "#proposal-title-tabs", en: "Test title for proposal"
      fill_in_i18n_editor :proposal_body, "#proposal-body-tabs", en: "Test description for proposal"
      select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"

      perform_enqueued_jobs { click_on "Create" }

      within(".evaluators-count") do
        expect(page).to have_content(evaluator.name)
      end
    end
  end

  context "when a proposal was published in public side" do
    it "has a evaluator after creating" do
      visit public_component_path

      click_on "New proposal"
      check "Has no address"
      check "Has no image"
      fill_in("proposal_title", with: "Test title for proposal")
      fill_in("proposal_body", with: "Test description for proposal")
      select decidim_sanitize_translated(taxonomy.name), from: "taxonomies-#{taxonomy_filter.id}"
      click_on "Continue"

      perform_enqueued_jobs { click_on "Publish" }

      visit manage_component_path(component)

      within(".evaluators-count") do
        expect(page).to have_content(evaluator.name)
      end
    end
  end
end
