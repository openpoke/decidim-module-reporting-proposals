# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatorySpaceRoleConfig
  describe Evaluator do
    subject { described_class.new(nil) }

    class TestEvaluator < Base
      def accepted_components
        [:proposals, :test]
      end
    end

    module TestEvaluatorOverride
      def accepted_components
        super + [:another_component]
      end
    end

    it "has default accepted components" do
      expect(subject.accepted_components).to contain_exactly(:proposals, :reporting_proposals)
    end

    context "when non default accepted components are added" do
      let(:alt_evaluator) { TestEvaluator.new(nil) }

      TestEvaluator.prepend(Decidim::ReportingProposals::ParticipatorySpaceRoleConfig::EvaluatorOverride)

      it "has default accepted components" do
        expect(alt_evaluator.accepted_components).to contain_exactly(:proposals, :test, :reporting_proposals)
        TestEvaluator.prepend(TestEvaluatorOverride)

        expect(alt_evaluator.accepted_components).to contain_exactly(:proposals, :test, :reporting_proposals, :another_component)
      end

      it "original class has default accepted components" do
        expect(subject.accepted_components).to contain_exactly(:proposals, :reporting_proposals)
      end
    end
  end
end
