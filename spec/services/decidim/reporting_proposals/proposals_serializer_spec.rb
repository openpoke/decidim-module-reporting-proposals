# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    describe ProposalSerializer do
      include Decidim::Proposals::Admin::ProposalsHelper

      subject do
        described_class.new(proposal)
      end

      let!(:proposal) { create(:proposal, :accepted) }
      let(:participatory_process) { component.participatory_space }
      let(:component) { proposal.component }

      let!(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }

      describe "#serialize" do
        let(:serialized) { subject.serialize }

        it "serializes the answer_time" do
          expect(serialized).to include(answer_time: time_elapsed_to_answer(proposal))
        end
      end
    end
  end
end
