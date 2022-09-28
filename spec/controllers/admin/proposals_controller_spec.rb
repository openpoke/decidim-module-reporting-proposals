# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  module Admin
    describe ProposalsController, type: :controller do
      routes { Decidim::ReportingProposals::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: proposal.component.organization) }
      let(:organization) { proposal.component.organization }
      let(:proposal) { create(:proposal) }
      let(:reportable) { proposal }
      let(:moderation) { create :moderation, reportable: reportable, report_count: 1, participatory_space: proposal.component.participatory_space }
      let!(:report) { create :report, moderation: moderation }

      let(:params) do
        {
          id: id
        }
      end

      let(:id) { proposal.id }

      before do
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
      end

      shared_examples "hide success" do
        it "hides the proposal" do
          put :hide_proposal, params: params
          expect(response).to have_http_status(:redirect)
          expect(controller.flash[:alert]).to be_blank
          expect(controller.flash[:notice]).to have_content("Resource successfully hidden")
          expect(Decidim::Proposals::Proposal.last).to be_hidden
        end
      end

      shared_examples "hide failure" do |msg|
        msg ||= "There was a problem hiding the resource"
        it "hides the proposal" do
          put :hide_proposal, params: params
          expect(response).to have_http_status(:redirect)
          expect(controller.flash[:notice]).to be_blank
          expect(controller.flash[:alert]).to have_content(msg)
          expect(Decidim::Proposals::Proposal.last).not_to be_hidden
        end
      end

      describe "#hide" do
        it_behaves_like "hide success"

        context "when proposal is not moderated" do
          let(:reportable) { create(:proposal) }

          it_behaves_like "hide failure"
        end

        context "when the user is not admin" do
          let(:user) { create(:user, :confirmed, organization: organization) }

          it_behaves_like "hide failure", "You are not authorized to perform this action"
        end

        context "when the user is not in the organization" do
          let(:user) { create(:user, :confirmed, :admin) }

          it_behaves_like "hide failure", "You are not authorized to perform this action"
        end

        context "when the proposal is not in the organization" do
          let(:user) { create(:user, :confirmed, :admin) }
          let(:organization) { user.organization }

          it_behaves_like "hide failure", "You are not authorized to perform this action"
        end
      end
    end
  end
end
