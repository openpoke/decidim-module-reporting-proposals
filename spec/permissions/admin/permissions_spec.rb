# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals::Admin
  describe Permissions do
    subject { described_class.new(user, permission_action, context).permissions.allowed? }

    let(:organization) { space.organization }
    let(:user) { build(:user, :admin, organization:) }
    let(:space) { current_component.participatory_space }
    let(:current_component) { create(:proposal_component) }
    let(:proposal) { create(:proposal, component: current_component) }
    let(:proposal_note) { create(:proposal_note, proposal:) }
    let(:context) do
      {
        proposal:,
        current_component:,
        current_settings: component_settings,
        component_settings:,
        proposal_note:
      }
    end
    let(:component_settings) do
      double(
        proposal_answering_enabled: proposal_answering_enabled?,
        proposal_photo_editing_enabled: proposal_photo_editing_enabled?,
        participatory_texts_enabled?: false
      )
    end
    let(:proposal_answering_enabled?) { true }
    let(:proposal_photo_editing_enabled?) { true }
    let(:allow_proposal_photo_editing) { true }
    let(:allow_admins_to_hide_proposals) { true }
    let(:valuators_assign_other_valuators) { true }
    let(:edit_proposal_note?) { true }
    let(:permission_action) { Decidim::PermissionAction.new(**action) }

    before do
      # rubocop:disable RSpec/ReceiveMessages
      allow(Decidim::ReportingProposals).to receive(:allow_proposal_photo_editing).and_return(allow_proposal_photo_editing)
      allow(Decidim::ReportingProposals).to receive(:allow_admins_to_hide_proposals).and_return(allow_admins_to_hide_proposals)
      allow(Decidim::ReportingProposals).to receive(:valuators_assign_other_valuators).and_return(valuators_assign_other_valuators)
      # rubocop:enable RSpec/ReceiveMessages
    end

    shared_examples "can answer proposals" do
      describe "proposal answering" do
        let(:action) do
          { scope: :admin, action: :create, subject: :proposal_answer }
        end

        context "when everything is OK" do
          it { is_expected.to be true }
        end

        context "when answering is disabled" do
          let(:proposal_answering_enabled?) { false }

          it { is_expected.to be false }
        end
      end
    end

    shared_examples "cannot edit photos" do
      describe "proposal photo modification" do
        let(:action) do
          { scope: :admin, action: :edit_photos, subject: :proposals }
        end

        it { is_expected.to be false }
      end
    end

    shared_examples "can edit photos" do
      describe "proposal photo modification" do
        let(:action) do
          { scope: :admin, action: :edit_photos, subject: :proposals }
        end

        context "when everything is OK" do
          it { is_expected.to be true }
        end

        context "when photo editing is disabled at the module level" do
          let(:allow_proposal_photo_editing) { false }

          it { is_expected.to be false }
        end

        context "when photo editing is disabled at the component level" do
          let(:proposal_photo_editing_enabled?) { false }

          it { is_expected.to be false }
        end
      end
    end

    shared_examples "can hide proposals" do
      describe "proposal moderation" do
        let(:action) do
          { scope: :admin, action: :hide_proposal, subject: :proposals }
        end

        context "when everything is OK" do
          it { is_expected.to be true }
        end

        context "when hide proposals is disabled" do
          let(:allow_admins_to_hide_proposals) { false }

          it { is_expected.to be false }
        end
      end
    end

    shared_examples "cannot hide proposals" do
      describe "proposal moderation" do
        let(:action) do
          { scope: :admin, action: :hide_proposal, subject: :proposals }
        end

        it { is_expected.to be false }
      end
    end

    shared_examples "can add valuators to the proposal" do
      describe "add other valuators" do
        let(:action) do
          { scope: :admin, action: :assign_to_valuator, subject: :proposals }
        end

        it { is_expected.to be true }
      end
    end

    shared_examples "cannot add valuators to the proposal" do
      describe "add other valuators" do
        let!(:valuators_assign_other_valuators) { false }

        let(:action) do
          { scope: :admin, action: :assign_to_valuator, subject: :proposals }
        end

        it { is_expected.to be false }
      end
    end

    shared_examples "edit proposal note" do
      describe "edit proposal note" do
        let(:action) do
          { scope: :admin, action: :edit_note, subject: :proposal_note }
        end

        let(:author) { create(:user, :admin, :confirmed, organization:) }

        context "when author edits his own note" do
          let!(:proposal_note) { create(:proposal_note, proposal:, author: user) }

          it { is_expected.to be true }
        end

        context "when the author of the note is a different user" do
          let!(:proposal_note) { create(:proposal_note, proposal:, author:) }

          it { is_expected.to be false }
        end
      end
    end

    it_behaves_like "can answer proposals"
    it_behaves_like "can edit photos"
    it_behaves_like "can hide proposals"
    it_behaves_like "edit proposal note"

    context "when user is a valuator" do
      let!(:valuator_role) { create(:participatory_process_user_role, user:, role: :valuator, participatory_process: space) }
      let!(:user) { create(:user, organization:) }

      it_behaves_like "cannot edit photos"
      it_behaves_like "cannot hide proposals"
      it_behaves_like "can add valuators to the proposal"
      it_behaves_like "cannot add valuators to the proposal"

      context "and can valuate the current proposal" do
        let!(:assignment) { create(:valuation_assignment, proposal:, valuator_role:) }

        it_behaves_like "can answer proposals"
        it_behaves_like "can edit photos"
        it_behaves_like "can hide proposals"
      end
    end

    context "when the user has no role" do
      let!(:user) { create(:user, organization:) }

      it_behaves_like "cannot edit photos"
      it_behaves_like "cannot hide proposals"
    end
  end
end
