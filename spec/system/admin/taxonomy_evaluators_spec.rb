# frozen_string_literal: true

require "spec_helper"
require "shared/taxonomy_evaluators_context"
require "decidim/assemblies/test/factories"

describe "Taxonomy evaluators" do
  include_context "with taxonomy evaluators"

  let!(:another_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, name: { en: "Street lighting" }) }
  let(:another_taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:another_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: another_taxonomy) }
  let!(:shared_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter: another_taxonomy_filter, taxonomy_item: taxonomy) }
  let!(:reporting_proposals_component) { create(:reporting_proposals_component, participatory_space:, settings: { taxonomy_filters: [another_taxonomy_filter.id] }) }
  let(:index_path) { Decidim::EngineRouter.admin_proxy(participatory_space).taxonomy_evaluators_path }

  shared_examples "manages taxonomy evaluators" do
    it "shows the menu item in the admin sidebar" do
      visit Decidim::EngineRouter.admin_proxy(participatory_space).components_path

      within "[id='admin-sidebar-menu-settings']" do
        click_on "Taxonomy evaluators"
      end

      expect(page).to have_content("Automatic taxonomy evaluators")
    end

    it "lists the taxonomies of every proposals component without duplicates, roots included" do
      visit index_path

      expect(page).to have_css("td", text: translated(root_taxonomy.name), count: 1)
      expect(page).to have_css("td", text: "Roads and pavements", count: 1)
      expect(page).to have_css("td", text: "Street lighting", count: 1)
      expect(page).to have_content("Unassigned", count: 3)
      within "tbody tr:first-child" do
        expect(page).to have_link(translated(root_taxonomy.name))
        expect(page).to have_link("Edit")
      end
    end

    context "when taxonomies are nested under different roots" do
      let!(:child_taxonomy) { create(:taxonomy, parent: taxonomy, organization:, name: { en: "Potholes" }) }
      let!(:child_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy) }
      let(:another_root_taxonomy) { create(:taxonomy, organization:, name: { en: "Environment" }) }
      let!(:parks_taxonomy) { create(:taxonomy, parent: another_root_taxonomy, organization:, name: { en: "Parks" }) }
      let(:environment_filter) { create(:taxonomy_filter, root_taxonomy: another_root_taxonomy) }
      let!(:parks_filter_item) { create(:taxonomy_filter_item, taxonomy_filter: environment_filter, taxonomy_item: parks_taxonomy) }
      let!(:proposals_component) { create(:proposal_component, participatory_space:, settings: { taxonomy_filters: [taxonomy_filter.id, environment_filter.id] }) }

      it "shows every taxonomy as its own row in tree order" do
        visit index_path

        expect(page).to have_css("td", text: "Environment", count: 1)
        expect(page).to have_css("td", text: "Parks", count: 1)
        expect(page).to have_css("td", text: "Potholes", count: 1)
        expect(page).to have_no_css("td", text: "Roads and pavements › Potholes")
        expect(page).to have_no_css("th[colspan]")
        # children are listed right below their parent
        expect(find("tbody").text).to match(/Roads and pavements.*Potholes.*Street lighting/m)
        expect(find("tbody").text).to match(/Environment.*Parks/m)
      end
    end

    it "assigns evaluators to a root taxonomy" do
      visit index_path

      within "tbody tr:first-child" do
        click_on "Edit"
      end

      expect(page).to have_content("Edit evaluators for #{translated(root_taxonomy.name)}")

      tom_select("#taxonomy_evaluators_evaluator_role_ids", option_id: [evaluator_role.id])
      click_on "Update"

      expect(page).to have_content("Evaluators successfully updated for this taxonomy.")
      # the root row and both inheriting children show the evaluator
      expect(page).to have_content(evaluator.name, count: 3)
      expect(page).to have_no_content("Unassigned")
    end

    context "when a parent taxonomy has evaluators assigned" do
      let!(:child_taxonomy) { create(:taxonomy, parent: taxonomy, organization:, name: { en: "Potholes" }) }
      let!(:child_taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: child_taxonomy) }
      let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }

      it "shows the inherited evaluators on the child" do
        visit index_path

        within "tr", text: "Potholes" do
          expect(page).to have_content(evaluator.name)
        end
        # the root and the sibling keep the unassigned state
        expect(page).to have_content("Unassigned", count: 2)
      end

      it "prefills the edit form of the inheriting child with the effective evaluators" do
        visit index_path

        within "tr", text: "Potholes" do
          click_on "Edit"
        end

        expect(page).to have_content("Edit evaluators for Potholes")
        expect(page).to have_css(".ts-control .item[data-value='#{evaluator_role.id}']", text: evaluator.name)
      end

      context "and the child has its own evaluators" do
        let!(:child_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy: child_taxonomy, evaluator_role: another_evaluator_role) }

        it "restores the inherited evaluators when the own ones are removed" do
          visit index_path

          within "tr", text: "Potholes" do
            expect(page).to have_content(another_evaluator.name)
            click_on "Edit"
          end

          tom_select("#taxonomy_evaluators_evaluator_role_ids", option_id: [])
          click_on "Update"

          expect(page).to have_content("Evaluators successfully updated for this taxonomy.")
          within "tr", text: "Potholes" do
            expect(page).to have_content(evaluator.name)
            expect(page).to have_no_content(another_evaluator.name)
          end
        end
      end
    end

    it "assigns evaluators to a taxonomy" do
      visit index_path

      within "tr", text: "Roads and pavements" do
        click_on "Edit"
      end

      expect(page).to have_content("Edit evaluators for Roads and pavements")

      tom_select("#taxonomy_evaluators_evaluator_role_ids", option_id: [evaluator_role.id, another_evaluator_role.id])
      click_on "Update"

      expect(page).to have_content("Evaluators successfully updated for this taxonomy.")
      within "tr", text: "Roads and pavements" do
        expect(page).to have_content(evaluator.name)
        expect(page).to have_content(another_evaluator.name)
      end
      within "tr", text: "Street lighting" do
        expect(page).to have_content("Unassigned")
      end
    end

    context "when evaluators are already assigned" do
      let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }
      let!(:another_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: another_evaluator_role) }

      it "removes an evaluator from a taxonomy" do
        visit index_path

        within "tr", text: "Roads and pavements" do
          expect(page).to have_content(evaluator.name)
          expect(page).to have_content(another_evaluator.name)
          click_on "Edit"
        end

        tom_select("#taxonomy_evaluators_evaluator_role_ids", option_id: [evaluator_role.id])
        click_on "Update"

        expect(page).to have_content("Evaluators successfully updated for this taxonomy.")
        within "tr", text: "Roads and pavements" do
          expect(page).to have_content(evaluator.name)
          expect(page).to have_no_content(another_evaluator.name)
        end
      end
    end

    context "when no proposals component has taxonomy filters" do
      let!(:proposals_component) { create(:proposal_component, participatory_space:) }
      let!(:reporting_proposals_component) { create(:reporting_proposals_component, participatory_space:) }

      it "shows an empty state" do
        visit index_path

        expect(page).to have_content("There are no taxonomies available")
      end
    end
  end

  context "when the participatory space is a participatory process" do
    let(:participatory_space) { create(:participatory_process, organization:) }
    let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: participatory_space) }
    let!(:another_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: another_evaluator, participatory_process: participatory_space) }

    it_behaves_like "manages taxonomy evaluators"

    it "shows the menu item right after the components" do
      visit index_path

      within "[id='admin-sidebar-menu-settings']" do
        expect(page.text).to match(/Components.*Taxonomy evaluators.*Attachments/m)
      end
    end

    context "when the user is a process admin" do
      let!(:user) { create(:process_admin, :confirmed, participatory_process: participatory_space) }

      it "can manage the taxonomy evaluators" do
        visit index_path

        expect(page).to have_content("Automatic taxonomy evaluators")
        within "[id='admin-sidebar-menu-settings']" do
          expect(page).to have_content("Taxonomy evaluators")
        end
      end
    end
  end

  context "when the participatory space is an assembly" do
    let(:participatory_space) { create(:assembly, organization:) }
    let!(:evaluator_role) { create(:assembly_user_role, role: :evaluator, user: evaluator, assembly: participatory_space) }
    let!(:another_evaluator_role) { create(:assembly_user_role, role: :evaluator, user: another_evaluator, assembly: participatory_space) }

    it_behaves_like "manages taxonomy evaluators"
  end
end
