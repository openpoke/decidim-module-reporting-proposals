# frozen_string_literal: true

require "spec_helper"
require "decidim/assemblies/test/factories"

module Decidim::ReportingProposals
  describe ParticipatorySpacePermissionsOverride do
    subject { permissions_class.new(user, permission_action, context).permissions.allowed? }

    let(:permissions_class) { Decidim::ParticipatoryProcesses::Permissions }
    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:context) { { current_participatory_space: participatory_space } }
    let(:action) { { scope: :admin, action: :update, subject: :taxonomy_evaluator } }
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    context "when the user is an organization admin" do
      let(:user) { create(:user, :admin, :confirmed, organization:) }

      it { is_expected.to be true }
    end

    context "when the user is an admin of the space" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:admin_role) { create(:participatory_process_user_role, user:, role: :admin, participatory_process: participatory_space) }

      it { is_expected.to be true }
    end

    context "when the user is an admin of another space" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:admin_role) { create(:participatory_process_user_role, user:, role: :admin, participatory_process: create(:participatory_process, organization:)) }

      it_behaves_like "permission is not set"
    end

    context "when the user is an evaluator of the space" do
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:evaluator_role) { create(:participatory_process_user_role, user:, role: :evaluator, participatory_process: participatory_space) }

      it_behaves_like "permission is not set"
    end

    context "when there is no user" do
      let(:user) { nil }

      it_behaves_like "permission is not set"
    end

    context "when the space is an assembly" do
      let(:permissions_class) { Decidim::Assemblies::Permissions }
      let(:participatory_space) { create(:assembly, organization:) }
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:admin_role) { create(:assembly_user_role, user:, role: :admin, assembly: participatory_space) }

      it { is_expected.to be true }
    end

    # sanity check: the override does not alter the upstream permissions
    context "when the action is a regular upstream one" do
      let(:action) { { scope: :admin, action: :update, subject: :process } }
      let(:user) { create(:user, :confirmed, organization:) }
      let!(:admin_role) { create(:participatory_process_user_role, user:, role: :admin, participatory_process: participatory_space) }

      it { is_expected.to be true }
    end
  end
end
