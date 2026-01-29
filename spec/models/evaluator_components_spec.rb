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
      extend ActiveSupport::Concern
      included do
        alias_method :test_original_accepted_components, :accepted_components

        def accepted_components
          test_original_accepted_components + [:another_component]
        end
      end
    end

    it "has default accepted components" do
      expect(subject.accepted_components).to contain_exactly(:proposals, :reporting_proposals)
    end

    context "when non default accepted components are added" do
      let(:alt_evaluator) { TestEvaluator.new(nil) }

      TestEvaluator.include(Decidim::ReportingProposals::ParticipatorySpaceRoleConfig::EvaluatorOverride)

      it "has default accepted components" do
        expect(alt_evaluator.accepted_components).to contain_exactly(:proposals, :test, :reporting_proposals)
        TestEvaluator.include(TestEvaluatorOverride)

        expect(alt_evaluator.accepted_components).to contain_exactly(:proposals, :test, :reporting_proposals, :another_component)
      end

      it "original class has default accepted components" do
        expect(subject.accepted_components).to contain_exactly(:proposals, :reporting_proposals)
      end
    end
  end
end
