# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { space.organization }
    let(:user) { build :user, organization: organization }
    let(:space) { current_component.participatory_space }
    let(:current_component) { create(:proposal_component) }
    let(:proposal) { create :proposal, component: current_component }
    let(:context) do
      {
        proposal: proposal,
        current_component: current_component
      }
    end

    let(:permission_action) { Decidim::PermissionAction.new(**action) }
    let(:action) do
      { scope: :anything, action: :locate, subject: :geolocation }
    end

    it { is_expected.to be true }

    context "when scope is admin" do
      let(:action) do
        { scope: :admin, action: :locate, subject: :geolocation }
      end

      it_behaves_like "permission is not set"
    end

    context "when other action" do
      let(:action) do
        { scope: :admin, action: :unknown, subject: :geolocation }
      end

      it_behaves_like "permission is not set"
    end

    context "when no user" do
      let(:user) { nil }

      it_behaves_like "permission is not set"
    end
  end
end
