# frozen_string_literal: true

require "spec_helper"

describe "Managing reporting proposals component trash" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }
  let(:admin_resource_path) { decidim_admin_participatory_processes.components_path(participatory_process) }
  let(:trash_path) { decidim_admin_participatory_processes.manage_trash_components_path(participatory_process) }
  let(:title) { { en: "My component" } }
  let!(:resource) { create(:reporting_proposals_component, participatory_space: participatory_process, name: title) }

  it_behaves_like "manage soft deletable component or space", "component"
  it_behaves_like "manage trashed resource", "component"
end
