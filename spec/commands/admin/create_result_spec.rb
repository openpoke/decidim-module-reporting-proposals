# frozen_string_literal: true

require "spec_helper"
require "decidim/accountability/test/factories"

module Decidim::Accountability
  describe Admin::CreateResult do
    subject { described_class.new(form) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:user) { create(:user, organization:) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:current_component) { create(:accountability_component, participatory_space: participatory_process) }
    let(:scope) { create(:scope, organization:) }
    let(:category) { create(:category, participatory_space: participatory_process) }

    let(:start_date) { Date.yesterday }
    let(:end_date) { Date.tomorrow }
    let(:status) { create(:status, component: current_component, key: "ongoing", name: { en: "Ongoing" }) }
    let(:progress) { 89 }
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
        component: current_component,
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

    context "when everything is ok" do
      let(:result) { Result.last }

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
            event: "decidim.events.accountability.proposal_linked",
            event_class: Decidim::Accountability::ProposalLinkedEvent,
            resource: kind_of(Result),
            affected_users: [proposal.creator_author],
            followers: [proposal_follower],
            extra: {
              proposal_id: proposal.id
            }
          )

        expect(Decidim::EventsManager)
          .to receive(:publish)
          .with(
            event: "decidim.events.accountability.proposal_linked",
            event_class: Decidim::Accountability::ProposalLinkedEvent,
            resource: kind_of(Result),
            affected_users: [reporting_proposal.creator_author],
            followers: [reporting_follower],
            extra: {
              proposal_id: reporting_proposal.id
            }
          )

        subject.call
      end
    end
  end
end
