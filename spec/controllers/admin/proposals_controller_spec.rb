# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  module Admin
    describe ProposalsController do
      routes { Decidim::ReportingProposals::AdminEngine.routes }

      let(:component) { create(:reporting_proposals_component) }
      let(:organization) { component.organization }
      let(:user) { create(:user, :confirmed, :admin, organization:) }
      let(:proposal) { create(:proposal, component:) }
      let(:reportable) { proposal }
      let(:moderation) { create(:moderation, reportable:, report_count: 1, participatory_space: component.participatory_space) }
      let!(:report) { create(:report, moderation:) }
      let(:image) do
        Rack::Test::UploadedFile.new(
          Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
          "image/jpeg"
        )
      end

      let(:params) do
        {
          id:
        }
      end

      let(:id) { proposal.id }
      let(:allow_proposal_photo_editing) { true }
      let(:allow_admins_to_hide_proposals) { true }

      before do
        # rubocop:disable RSpec/ReceiveMessages
        allow(Decidim::ReportingProposals).to receive(:allow_proposal_photo_editing).and_return(allow_proposal_photo_editing)
        allow(Decidim::ReportingProposals).to receive(:allow_admins_to_hide_proposals).and_return(allow_admins_to_hide_proposals)
        request.env["decidim.current_organization"] = organization
        sign_in user, scope: :user
        # rubocop:enable RSpec/ReceiveMessages
      end

      shared_examples "hide success" do
        it "hides the proposal" do
          put(:hide_proposal, params:)
          expect(response).to have_http_status(:redirect)
          expect(controller.flash[:alert]).to be_blank
          expect(controller.flash[:notice]).to have_content("Resource successfully hidden")
          expect(proposal.reload).to be_hidden
        end
      end

      shared_examples "hide failure" do |msg|
        msg ||= "There was a problem hiding the resource"
        it "hides the proposal" do
          put(:hide_proposal, params:)
          expect(response).to have_http_status(:redirect)
          expect(controller.flash[:notice]).to be_blank
          expect(controller.flash[:alert]).to have_content(msg)
          expect(proposal.reload).not_to be_hidden
        end
      end

      shared_examples "can edit photos" do
        it "allows to add photos" do
          post(:add_photos, params:)
          expect(response).to have_http_status(:redirect)
          expect(controller.flash[:alert]).to be_blank
          expect(controller.flash[:notice]).to have_content("Proposal successfully updated")
          expect(Decidim::Proposals::Proposal.last.photos.count).to be_positive
        end
      end

      shared_examples "cannot edit photos" do
        it "does not allow to add photos" do
          post(:add_photos, params:)
          expect(response).to have_http_status(:redirect)
          expect(controller.flash[:notice]).to be_blank
          expect(controller.flash[:alert]).to have_content("There was a problem saving the proposal")
          expect(Decidim::Proposals::Proposal.last.photos.count).to be_zero
        end
      end

      shared_examples "can remove photo" do
        it "allows to remove photos" do
          delete(:remove_photo, params:)
          expect(response).to have_http_status(:redirect)
          expect(controller.flash[:alert]).to be_blank
          expect(controller.flash[:notice]).to have_content("Proposal successfully updated")
          expect(Decidim::Proposals::Proposal.last.photos.count).to be_zero
        end
      end

      shared_examples "cannot remove photo" do
        it "does not allow to remove photos" do
          delete(:remove_photo, params:)
          expect(response).to have_http_status(:redirect)
          expect(controller.flash[:notice]).to be_blank
          expect(controller.flash[:alert]).to have_content("There was a problem saving the proposal")
          expect(Decidim::Proposals::Proposal.last.photos.count).to be_positive
        end
      end

      describe "#hide_photos" do
        it_behaves_like "hide success"

        context "when proposal is not moderated" do
          let(:reportable) { create(:proposal) }

          it_behaves_like "hide failure"
        end

        context "when the user is not admin" do
          let(:user) { create(:user, :confirmed, organization:) }

          it_behaves_like "hide failure", ""
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

      describe "#add_photos" do
        let(:params) do
          {
            id:,
            add_photos: [image]
          }
        end

        it_behaves_like "can edit photos"

        context "when no attachment" do
          let(:params) do
            {
              id:
            }
          end

          it_behaves_like "cannot edit photos"
        end
      end

      describe "#remove_photo" do
        let(:proposal) { create(:proposal, :with_photo, component:) }
        let(:params) do
          {
            id:,
            photo_id: proposal.photo.id
          }
        end

        it_behaves_like "can remove photo"

        context "when no photo id" do
          let(:params) do
            {
              id:
            }
          end

          it_behaves_like "cannot remove photo"
        end
      end
    end
  end
end
