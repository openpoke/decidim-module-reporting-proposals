# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals::Admin
  describe ProposalAnswersController do
    let(:component) { create(:reporting_proposals_component) }
    let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
    let(:proposal) { create(:proposal, component:) }
    let(:params) do
      {
        id: proposal.id,
        internal_state:,
        component_id: component.id,
        participatory_process_slug: component.participatory_space.slug
      }
    end

    before do
      sign_in user
      request.env["decidim.current_organization"] = component.organization
      request.env["decidim.current_participatory_space"] = component.participatory_space
      request.env["decidim.current_component"] = component
    end

    describe "PUT update" do
      context "when the update is successful" do
        let(:internal_state) { "accepted" }
        let(:proposals_path) { "/decidim/proposals/admin/proposals/index" }

        before { allow(controller).to receive(:proposals_path).and_return(proposals_path) }

        it "redirects to the proposals list" do
          put(:update, params:)

          expect(response).to redirect_to(proposals_path)
        end
      end

      context "when the answer is not valid" do
        let(:internal_state) { "" }

        it "renders the proposal page with the photo form" do
          put(:update, params:)

          expect(response).to have_http_status(:unprocessable_content)
          expect(controller.view_assigns["photo_form"]).to be_a(Decidim::ReportingProposals::Admin::ProposalPhotoForm)
        end
      end
    end
  end
end
