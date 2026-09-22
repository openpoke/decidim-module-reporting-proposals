# frozen_string_literal: true

require "spec_helper"
require "shared/taxonomy_evaluators_context"

describe "Taxonomy evaluators edit" do
  include_context "with taxonomy evaluators"

  let(:participatory_space) { create(:participatory_process, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: participatory_space) }
  let!(:another_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: another_evaluator, participatory_process: participatory_space) }
  let(:edit_path) { Decidim::EngineRouter.admin_proxy(participatory_space).edit_taxonomy_evaluator_path(id: taxonomy.id) }

  context "when evaluators are already assigned" do
    let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }
    let!(:another_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: another_evaluator_role) }

    it "preselects the assigned evaluators in the multiselect" do
      visit edit_path

      expect(page).to have_content("Edit evaluators for Roads and pavements")
      within "form.edit_taxonomy_evaluators" do
        expect(page).to have_css(".ts-control .item[data-value='#{evaluator_role.id}']", text: evaluator.name)
        expect(page).to have_css(".ts-control .item[data-value='#{another_evaluator_role.id}']", text: another_evaluator.name)
      end
    end
  end

  context "when submitting an evaluator role from another participatory space" do
    let(:other_participatory_process) { create(:participatory_process, organization:) }
    let(:foreign_evaluator) { create(:user, :confirmed, organization:, name: "Foreign Evaluator") }
    let!(:foreign_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: foreign_evaluator, participatory_process: other_participatory_process) }

    it "re-renders the edit form with an alert" do
      visit edit_path

      # Inject an option outside the space roles to emulate a forged submission
      page.execute_script(
        %{document.querySelector("#taxonomy_evaluators_evaluator_role_ids").tomselect.addOption({value: "#{foreign_evaluator_role.id}", text: "Foreign Evaluator"});}
      )
      tom_select("#taxonomy_evaluators_evaluator_role_ids", option_id: [foreign_evaluator_role.id])
      click_on "Update"

      expect(page).to have_content("There was a problem updating the evaluators for this taxonomy.")
      expect(page).to have_content("Edit evaluators for Roads and pavements")
      expect(Decidim::ReportingProposals::TaxonomyEvaluator.count).to eq(0)
    end
  end
end
