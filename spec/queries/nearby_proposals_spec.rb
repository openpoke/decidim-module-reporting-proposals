# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  describe NearbyProposals do
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:component) { create(:reporting_proposals_component, participatory_space: participatory_process, settings: settings) }
    let(:settings) do
      {
        "geocoding_comparison_radius" => radius,
        "geocoding_comparison_newer_than" => newer_than
      }
    end
    let(:radius) { 30 }
    let(:newer_than) { 60 }
    let!(:proposal_missed) { create(:proposal, component: component, longitude: longitude_missed, latitude: latitude_missed, published_at: published_missed) }
    let!(:proposal_far) { create(:proposal, component: component, longitude: longitude_far, latitude: latitude_far, published_at: published_far) }
    let!(:proposal_near) { create(:proposal, component: component, longitude: longitude_near, latitude: latitude_near, published_at: published_near) }
    let!(:proposal) { create(:proposal, component: component, longitude: longitude, latitude: latitude) }

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

    let(:published_near) { 10.days.ago }
    let(:published_far) { 30.days.ago }
    let(:published_missed) { 50.days.ago }
    let(:result) { described_class.for([component], proposal).map(&:id) }

    it "finds 2 proposals and exclude 1" do
      expect(result).to eq([proposal.id, proposal_near.id, proposal_far.id])
      expect(result).not_to eq([proposal.id, proposal_far.id, proposal_near.id])
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

    context "when no proposals are found" do
      let(:proposal) { create(:proposal, :draft, component: component, longitude: nil, latitude: nil) }

      it "finds nothing" do
        expect(result).to be_blank
      end
    end

    context "when proposal has no coordinates" do
      let(:radius) { 40 }
      let(:latitude_far) { nil }

      it "fins the ones that do" do
        expect(result).to eq([proposal.id, proposal_near.id, proposal_missed.id])
      end
    end

    context "when proposal is older than settings" do
      let(:newer_than) { 40 }
      let(:radius) { 40 }

      it "fins only the new ones" do
        expect(result).to eq([proposal.id, proposal_near.id, proposal_far.id])
      end
    end

    context "when settings is 0 days" do
      let(:newer_than) { 0 }
      let(:radius) { 40 }

      it "does not filter by date" do
        expect(result).to eq([proposal.id, proposal_near.id, proposal_far.id, proposal_missed.id])
      end
    end

    context "when belong to another component" do
      let(:proposal_far) { create(:proposal, longitude: longitude_far, latitude: latitude_far, published_at: published_far) }

      it "is not found" do
        expect(result).to eq([proposal.id, proposal_near.id])
      end
    end

    context "when it is not published" do
      let(:proposal_far) { create(:proposal, :unpublished, component: component, longitude: longitude_far, latitude: latitude_far) }

      it "is not found" do
        expect(result).to eq([proposal.id, proposal_near.id])
      end
    end

    context "when it is hidden" do
      let(:proposal_far) { create(:proposal, :hidden, component: component, longitude: longitude_far, latitude: latitude_far) }

      it "is not found" do
        expect(result).to eq([proposal.id, proposal_near.id])
      end
    end

    context "when the similarity limit is reached" do
      let(:radius) { 40 }

      before do
        allow(Decidim::Proposals).to receive(:similarity_limit).and_return(2)
      end

      it "only shows the number allowed" do
        expect(result).to eq([proposal.id, proposal_near.id])
      end
    end
  end
end
