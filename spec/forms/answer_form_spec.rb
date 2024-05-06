# frozen_string_literal: true

require "spec_helper"
require "decidim/elections/test/factories"

module Decidim::Elections::Admin
  describe AnswerForm do
    subject { described_class.from_model(answer).with_context(context) }

    let(:context) do
      {
        current_organization: component.organization,
        current_component: component,
        election:,
        question:
      }
    end
    let(:election) { question.election }
    let(:question) { create(:question) }
    let(:component) { election.component }
    let(:proposals_component) { create(:component, manifest_name: :proposals, participatory_space: component.participatory_space) }
    let(:proposals) { create_list(:proposal, 2, component: proposals_component) }
    let(:reporting_component) { create(:component, manifest_name: :reporting_proposals, participatory_space: component.participatory_space) }
    let(:reporting_proposals) { create_list(:proposal, 2, component: reporting_component) }
    let(:answer) { create(:election_answer, question:) }

    before do
      answer.link_resources(proposals + reporting_proposals, "related_proposals")
    end

    describe "#map_model" do
      it "sets the proposal_ids correctly" do
        expect(subject.proposal_ids).to match_array(proposals.map(&:id) + reporting_proposals.map(&:id))
      end
    end

    describe "#proposals" do
      it "returns the available proposals in a way suitable for the form" do
        expect(subject.proposals).to match_array(proposals + reporting_proposals)
      end
    end
  end
end
