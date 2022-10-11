# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class ProposalsController < Admin::ApplicationController
        def hide_proposal
          enforce_permission_to :hide_proposal, :proposals, proposal: proposal

          Decidim::Admin::HideResource.call(proposal, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("reportable.hide.success", scope: "decidim.moderations.admin")
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("reportable.hide.invalid", scope: "decidim.moderations.admin")
            end
          end
          redirect_back(fallback_location: decidim_admin.root_path)
        end

        def add_photos
          enforce_permission_to :edit_photos, :proposals, proposal: proposal

          @photo_form = form(Decidim::ReportingProposals::Admin::ProposalPhotoForm).from_params(params)

          Decidim::ReportingProposals::Admin::UpdateProposal.call(@photo_form, proposal) do
            on(:ok) do |_proposal|
              flash[:notice] = t("proposals.update.success", scope: "decidim")
            end

            on(:invalid) do
              flash[:alert] = t("proposals.update.error", scope: "decidim")
            end
          end
          redirect_to Decidim::ResourceLocatorPresenter.new(proposal).show
        end

        def remove_photo
          enforce_permission_to :edit_photos, :proposals, proposal: proposal

          attachment = proposal.attachments.find_by(id: params[:photo_id])
          if attachment.try(:photo?)
            attachment.destroy!
            flash[:notice] = t("proposals.update.success", scope: "decidim")
          else
            flash[:alert] = t("proposals.update.error", scope: "decidim")
          end

          redirect_to Decidim::ResourceLocatorPresenter.new(proposal).show
        end

        private

        def proposal
          @proposal ||= Decidim::Proposals::Proposal.find(params[:id])
        end
      end
    end
  end
end
