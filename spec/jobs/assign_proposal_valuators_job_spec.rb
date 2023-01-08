# frozen_string_literal: true

module Decidim::ReportingProposals
  describe AssignProposalValuatorsJob do
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:category) { create(:category, participatory_space: participatory_process) }
    let!(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let!(:proposal) { create :proposal, :unpublished, component: component, category: category }
    let(:data) do
      {
        affected_users: [],
        event_class: "Decidim::Proposals::PublishProposalEvent",
        extra: {},
        followers: [],
        force_send: false,
        resource: proposal
      }
    end

    context "when publishing a proposal" do
      subject do
        Decidim::Proposals::PublishProposal.new(proposal, proposal.authors.first)
      end

      it "broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end

      it "enqueues the job twice" do
        expect(Decidim::ReportingProposals::AssignProposalValuatorsJob).to receive(:perform_later).with(data)
        expect(Decidim::ReportingProposals::AssignProposalValuatorsJob).to receive(:perform_later).with(data.merge(extra: { participatory_space: true }))
        subject.call
      end
    end
  end
end
