# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe ProposalsController do
    let(:component) { create(:reporting_proposals_component, settings:) }
    let(:settings) { {} }
    let(:organization) { component.organization }
    let(:current_user) { create(:user, :confirmed, organization:) }

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
        let(:proposal) { create(:proposal, component:, latitude: nil, longitude: nil) }

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

    describe "GET compare" do
      let(:proposal) { create(:proposal, :draft, component:, users: [current_user]) }

      it "redirects to the preview when there are no similar proposals" do
        get :compare, params: { id: proposal.id }

        expect(response).to redirect_to("#{Decidim::ResourceLocatorPresenter.new(proposal).path}/preview")
      end

      context "when the proposal belongs to another component" do
        let(:proposal) { create(:proposal, :draft, component: create(:reporting_proposals_component, organization:), users: [current_user]) }

        it "does not find the proposal" do
          expect { get :compare, params: { id: proposal.id } }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the proposal is hidden" do
        let(:proposal) { create(:proposal, :hidden, component:, users: [current_user]) }

        it "does not find the proposal" do
          expect { get :compare, params: { id: proposal.id } }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end

      context "when the proposal is already published" do
        let(:proposal) { create(:proposal, component:, users: [current_user]) }

        it "redirects to the proposal" do
          get :compare, params: { id: proposal.id }

          expect(response).to redirect_to(Decidim::ResourceLocatorPresenter.new(proposal).path)
        end
      end
    end

    context "when component is a normal proposal component" do
      let(:component) { create(:proposal_component, settings:) }

      it "is aware of not being reporting_proposals_component" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(controller.helpers).not_to be_reporting_proposal
      end

      it_behaves_like "geocoding comparison", false
    end
  end
end
