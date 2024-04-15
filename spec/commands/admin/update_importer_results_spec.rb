# frozen_string_literal: true

require "spec_helper"
require "decidim/accountability/test/factories"

module Decidim::Accountability
  describe Admin::UpdateImportedResult do
    subject { described_class.new(form, result) }

    let(:result) { create(:result, progress: 10) }
    let(:organization) { result.component.organization }
    let(:user) { create(:user, organization:) }
    let(:scope) { create(:scope, organization:) }
    let(:category) { create(:category, participatory_space: participatory_process) }
    let(:participatory_process) { result.component.participatory_space }
    let(:start_date) { Date.yesterday }
    let(:end_date) { Date.tomorrow }
    let(:status) { create(:status, component: result.component, key: "finished", name: { en: "Finished" }) }
    let(:progress) { 95 }
    let(:external_id) { "external-id" }
    let(:weight) { 0.3 }

    let(:proposal_component) do
      create(:component, manifest_name: :proposals, participatory_space: participatory_process)
    end
    let(:proposal) { create(:proposal, component: proposal_component) }
    let(:reporting_component) do
      create(:component, manifest_name: :reporting_proposals, participatory_space: participatory_process)
    end
    let(:reporting_proposal) { create(:proposal, component: reporting_component) }

    let(:form) do
      double(
        invalid?: invalid,
        title: { en: "title" },
        description: { en: "description" },
        proposal_ids: [proposal.id, reporting_proposal.id],
        project_ids: [],
        scope:,
        category:,
        start_date:,
        end_date:,
        decidim_accountability_status_id: status.id,
        progress:,
        current_user: user,
        parent_id: nil,
        external_id:,
        weight:
      )
    end
    let(:invalid) { false }

    it "updates the result" do
      subject.call
      expect(translated(result.title)).to eq "title"
    end

    it "links proposals" do
      subject.call
      linked_proposals = result.linked_resources(:proposals, "included_proposals") + result.linked_resources(:reporting_proposals, "included_proposals")
      expect(linked_proposals).to contain_exactly(proposal, reporting_proposal)
    end

    it "notifies the linked proposals followers" do
      proposal_follower = create(:user, organization:)
      reporting_follower = create(:user, organization:)
      create(:follow, followable: proposal, user: proposal_follower)
      create(:follow, followable: reporting_proposal, user: reporting_follower)

      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.accountability.result_progress_updated",
          event_class: Decidim::Accountability::ResultProgressUpdatedEvent,
          resource: result,
          affected_users: [proposal.creator_author],
          followers: [proposal_follower],
          extra: {
            progress:,
            proposal_id: proposal.id
          }
        )

      expect(Decidim::EventsManager)
        .to receive(:publish)
        .with(
          event: "decidim.events.accountability.result_progress_updated",
          event_class: Decidim::Accountability::ResultProgressUpdatedEvent,
          resource: result,
          affected_users: [reporting_proposal.creator_author],
          followers: [reporting_follower],
          extra: {
            progress:,
            proposal_id: reporting_proposal.id
          }
        )

      subject.call
    end
  end
end
