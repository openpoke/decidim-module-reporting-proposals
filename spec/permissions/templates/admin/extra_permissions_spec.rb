# frozen_string_literal: true

require "spec_helper"

module Decidim::Templates::Admin
  describe ExtraPermissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:user) { create(:user, :confirmed, :admin_terms_accepted, organization:) }
    let!(:valuator_role) { create(:participatory_process_user_role, role: :valuator, user:, participatory_process:) }
    let(:current_component) { create(:proposal_component, participatory_space: participatory_process) }
    let(:proposal) { create(:proposal, component: current_component) }
    let(:context) do
      {
        proposal:,
        current_organization: organization,
        current_component:,
        current_settings: component_settings,
        component_settings:
      }
    end
    let(:component_settings) do
      double(
        proposal_answering_enabled: true
      )
    end
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    describe "template reading" do
      let(:action) do
        { scope: :admin, action: :read, subject: :template }
      end

      context "when everything is OK" do
        it { is_expected.to be true }
      end

      context "when user has no admin role" do
        let(:valuator_role) { nil }

        it_behaves_like "permission is not set"
      end
    end
  end
end
