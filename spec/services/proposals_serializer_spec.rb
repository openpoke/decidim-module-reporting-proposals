# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalSerializer do
    include Decidim::Proposals::Admin::ProposalsHelper

    subject do
      described_class.new(proposal)
    end

    let!(:proposal) { create(:proposal, :accepted) }
    let!(:unanswered_proposal) { create(:proposal, :not_answered) }
    let(:participatory_process) { component.participatory_space }
    let(:component) { proposal.component }

    let!(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }

    describe "#serialize" do
      let(:serialized) { subject.serialize }

      it "serializes the answer_time" do
        expect(serialized).to include(answer_time: "#{I18n.t("decidim.reporting_proposals.admin.resolution_time")}: #{time_elapsed_to_answer(proposal)}")
      end

      context "when proposal is not answered" do
        let(:proposal) { unanswered_proposal }

        it "serializes the due time" do
          expect(serialized).to include(answer_time: time_ago_in_words(last_day_to_answer(proposal),
                                                                       scope: "decidim.reporting_proposals.admin.answer_pending.datetime.distance_in_words"))
        end
      end
    end

    describe "#answer_time" do
      context "when the proposal is unanswered and overdue" do
        before do
          allow(subject).to receive(:unanswered_proposals_overdue?).with(proposal).and_return(true)
        end

        it "returns the time in words since the last day to answer the proposal" do
          expect(subject.answer_time).to eq(time_ago_in_words(last_day_to_answer(proposal), scope: "decidim.reporting_proposals.admin.answer_overdue.datetime.distance_in_words"))
        end
      end

      context "when the proposal is in evaluation and overdue" do
        before do
          allow(subject).to receive(:evaluating_proposals_overdue?).with(proposal).and_return(true)
        end

        it "returns the time in words since the last day to evaluate the proposal" do
          expect(subject.answer_time).to eq(time_ago_in_words(last_day_to_evaluate(proposal), scope: "decidim.reporting_proposals.admin.answer_overdue.datetime.distance_in_words"))
        end
      end

      context "when the proposal is unanswered and in grace period" do
        before do
          allow(subject).to receive(:grace_period_unanswered?).with(proposal).and_return(true)
        end

        it "returns the time in words until the last day to answer the proposal" do
          expect(subject.answer_time).to eq(time_ago_in_words(last_day_to_answer(proposal), scope: "decidim.reporting_proposals.admin.answer_pending.datetime.distance_in_words"))
        end
      end

      context "when the proposal is in evaluation and in grace period" do
        before do
          allow(subject).to receive(:grace_period_evaluating?).with(proposal).and_return(true)
        end

        it "returns the time in words until the last day to evaluate the proposal" do
          expect(subject.answer_time).to eq(time_ago_in_words(last_day_to_evaluate(proposal), scope: "decidim.reporting_proposals.admin.evaluate_pending.datetime.distance_in_words"))
        end
      end
    end
  end
end
