# frozen_string_literal: true

require "spec_helper"

module Decidim::ParticipatorySpaceRoleConfig
  describe Valuator do
    subject { described_class }

    it "has default accepted components" do
      expect(subject.new(nil).accepted_components).to match_array([:proposals, :reporting_proposals])
    end

    context "when non default accepted components are added" do
      subject { TestValuator }

      class TestValuator < Base
        def accepted_components
          [:proposals, :test]
        end
        # simulate the inclusion of the concern after definition
        include(Decidim::ReportingProposals::ParticipatorySpaceRoleConfig::ValuatorOverride)
      end

      it "has default accepted components" do
        expect(subject.new(nil).accepted_components).to match_array([:proposals, :test, :reporting_proposals])
      end

      it "original class has default accepted components" do
        expect(Valuator.new(nil).accepted_components).to match_array([:proposals, :reporting_proposals])
      end
    end
  end
end
