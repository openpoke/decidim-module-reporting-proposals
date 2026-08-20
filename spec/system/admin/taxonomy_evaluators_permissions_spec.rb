# frozen_string_literal: true

require "spec_helper"
require "shared/taxonomy_evaluators_context"
require "decidim/assemblies/test/factories"
require "decidim/admin/test/admin_participatory_space_access_examples"

describe "Taxonomy evaluators permissions" do
  include_context "with taxonomy evaluators"

  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:index_path) { Decidim::EngineRouter.admin_proxy(participatory_space).taxonomy_evaluators_path }
  let(:edit_path) { Decidim::EngineRouter.admin_proxy(participatory_space).edit_taxonomy_evaluator_path(id: taxonomy.id) }

  shared_examples "denies access to taxonomy evaluators management" do
    context "and visits the taxonomy evaluators index" do
      before { visit index_path }

      it_behaves_like "showing the unauthorized error message"
    end

    context "and visits the taxonomy evaluators edit page" do
      before { visit edit_path }

      it_behaves_like "showing the unauthorized error message"
    end
  end

  context "when the user has no admin roles" do
    let!(:user) { create(:user, :confirmed, organization:) }

    it "redirects away from the taxonomy evaluators index" do
      visit index_path

      expect(page).to have_current_path("/admin/")
      expect(page).to have_no_content("Taxonomy evaluators")
    end

    it "redirects away from the taxonomy evaluators edit page" do
      visit edit_path

      expect(page).to have_current_path("/admin/")
      expect(page).to have_no_content("Roads and pavements")
    end
  end

  context "when the user is an evaluator of the participatory process" do
    let!(:user) { create(:process_evaluator, :confirmed, participatory_process: participatory_space) }

    it_behaves_like "denies access to taxonomy evaluators management"

    it "does not show the menu item in the admin sidebar" do
      visit Decidim::EngineRouter.admin_proxy(participatory_space).components_path

      expect(page).to have_css("[id='admin-sidebar-menu-settings']")
      within "[id='admin-sidebar-menu-settings']" do
        expect(page).to have_content("Components")
        expect(page).to have_no_content("Taxonomy evaluators")
      end
    end
  end

  context "when the user is a collaborator of the participatory process" do
    let!(:user) { create(:process_collaborator, :confirmed, participatory_process: participatory_space) }

    it_behaves_like "denies access to taxonomy evaluators management"
  end

  context "when the user is a moderator of the participatory process" do
    let!(:user) { create(:process_moderator, :confirmed, participatory_process: participatory_space) }

    it_behaves_like "denies access to taxonomy evaluators management"
  end

  context "when the user is an admin of another participatory process" do
    let(:other_participatory_process) { create(:participatory_process, organization:) }
    let!(:user) { create(:process_admin, :confirmed, participatory_process: other_participatory_process) }

    it_behaves_like "denies access to taxonomy evaluators management"
  end

  context "when the participatory space is an assembly" do
    let(:assembly) { create(:assembly, organization:) }
    let(:assembly_index_path) { Decidim::EngineRouter.admin_proxy(assembly).taxonomy_evaluators_path }

    context "and the user is an evaluator of the assembly" do
      let!(:user) { create(:assembly_evaluator, :confirmed, assembly:) }

      before { visit assembly_index_path }

      it_behaves_like "showing the unauthorized error message"
    end
  end

  context "when the user is an admin" do
    context "and edits a taxonomy from another organization" do
      let(:other_root_taxonomy) { create(:taxonomy) }
      let(:other_organization_taxonomy) { create(:taxonomy, parent: other_root_taxonomy, organization: other_root_taxonomy.organization) }

      it_behaves_like "a 404 page" do
        let(:target_path) { Decidim::EngineRouter.admin_proxy(participatory_space).edit_taxonomy_evaluator_path(id: other_organization_taxonomy.id) }
      end
    end

    context "and edits a taxonomy not used by the proposals components of the space" do
      let(:unrelated_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, name: { en: "Unrelated" }) }

      it_behaves_like "a 404 page" do
        let(:target_path) { Decidim::EngineRouter.admin_proxy(participatory_space).edit_taxonomy_evaluator_path(id: unrelated_taxonomy.id) }
      end
    end
  end
end
