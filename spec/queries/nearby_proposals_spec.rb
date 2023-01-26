# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  describe NearbyProposals do
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:component) { create(:reporting_proposals_component, participatory_space: participatory_process, settings: settings) }
    let(:settings) do
      {
        "geocoding_comparison_radius" => radius
      }
    end
    let(:radius) { 30 }
    let!(:proposal) { create(:proposal, component: component, longitude: longitude, latitude: latitude) }
    let!(:proposal_near) { create(:proposal, component: component, longitude: longitude_near, latitude: latitude_near) }
    let!(:proposal_far) { create(:proposal, component: component, longitude: longitude_far, latitude: latitude_far) }
    let!(:proposal_missed) { create(:proposal, component: component, longitude: longitude_missed, latitude: latitude_missed) }

    # 41.4273° N, 2.1815° E (Canodrom, Barcelona)
    let(:latitude) { 41.4273 }
    let(:longitude) { 2.1815 }
    # 10 meters away
    let(:latitude_near) { 41.42737 }
    let(:longitude_near) { 2.18157 }
    # 20 meters away
    let(:latitude_far) { 41.42744 }
    let(:longitude_far) { 2.18165 }
    # 35 meters away
    let(:latitude_missed) { 41.42758 }
    let(:longitude_missed) { 2.1817 }

    let(:result) { described_class.for([component], proposal).map(&:id) }

    it "finds 2 proposals and exclude 1" do
      expect(result).to eq([proposal.id, proposal_near.id, proposal_far.id])
    end

    context "when radius is 15 meters" do
      let(:radius) { 15 }

      it "finds 1 proposal and exclude 2" do
        expect(result).to eq([proposal.id, proposal_near.id])
      end
    end

    context "when radius is 40 meters" do
      let(:radius) { 40 }

      it "finds all proposals" do
        expect(result).to eq([proposal.id, proposal_near.id, proposal_far.id, proposal_missed.id])
      end
    end

    context "when radius is 0 meters" do
      let(:radius) { 0 }

      it "finds nothing" do
        expect(result).to eq([proposal.id])
      end
    end

    context "when radius is 1 meters" do
      let(:radius) { 1 }

      it "finds nothing" do
        expect(result).to eq([proposal.id])
      end
    end

    context "when proposal has no coordinates" do
      let(:radius) { 40 }
      let(:latitude_far) { nil }

      it "fins the ones that do" do
        expect(result).to eq([proposal.id, proposal_near.id, proposal_missed.id])
      end
    end
  end
end
