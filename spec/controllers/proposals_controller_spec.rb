# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalsController, type: :controller do
    routes { Decidim::Proposals::Engine.routes }

    let(:component) { create(:reporting_proposals_component, settings: settings) }
    let(:settings) { {} }
    let(:organization) { component.organization }
    let(:current_user) { create(:user, :confirmed, organization: organization) }

    before do
      request.env["decidim.current_organization"] = organization
      request.env["decidim.current_participatory_space"] = component.participatory_space
      request.env["decidim.current_component"] = component
      sign_in current_user, scope: :user
    end

    shared_examples "geocoding comparison" do |enabled|
      it "has geocoding helper" do
        get :index
        expect(controller.helpers.geocoding_comparison?).to(enabled ? be_truthy : be_falsey)
      end

      context "when settings is enabled" do
        let(:settings) do
          {
            "geocoding_enabled" => true,
            "geocoding_comparison_enabled" => true
          }
        end

        it "geocoding comparison is on" do
          get :index
          expect(controller.helpers).to be_geocoding_comparison
        end
      end

      context "when geocoding is disabled" do
        let(:settings) do
          {
            "geocoding_enabled" => false,
            "geocoding_comparison_enabled" => true
          }
        end

        it "geocoding comparison is off" do
          get :index
          expect(controller.helpers).not_to be_geocoding_comparison
        end
      end

      context "when geocoding comparison is disabled" do
        let(:settings) do
          {
            "geocoding_enabled" => true,
            "geocoding_comparison_enabled" => false
          }
        end

        it "geocoding comparison is off" do
          get :index
          expect(controller.helpers).not_to be_geocoding_comparison
        end
      end

      context "when geocoding is not configured" do
        before do
          allow(Decidim::Map).to receive(:configured?).and_return(false)
        end

        it "geocoding comparison is off" do
          get :index
          expect(controller.helpers).not_to be_geocoding_comparison
        end
      end

      context "when proposal is not geocoded" do
        let(:proposal) { create(:proposal, component: component, latitude: nil, longitude: nil) }

        it "geocoding comparison is off" do
          get :show, params: { id: proposal.id }
          expect(controller.helpers).not_to be_geocoding_comparison
        end
      end
    end

    it "is aware of being reporting_proposals_component" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(controller.helpers).to be_reporting_proposal
    end

    it_behaves_like "geocoding comparison", true

    context "when component is a normal proposal component" do
      let(:component) { create(:proposal_component, settings: settings) }

      it "is aware of not being reporting_proposals_component" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(controller.helpers).not_to be_reporting_proposal
      end

      it_behaves_like "geocoding comparison", false
    end
  end
end
