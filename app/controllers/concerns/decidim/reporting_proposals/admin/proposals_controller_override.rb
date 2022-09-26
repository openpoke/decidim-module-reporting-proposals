# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalsControllerOverride
        extend ActiveSupport::Concern

        included do
          helper_method :proposals, :query, :form_presenter, :proposal, :proposal_ids, :hide

          def hide
            Decidim::Admin::HideResource.call(proposal, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("reportable.hide.success", scope: "decidim.moderations.admin")
                redirect_to proposals_path
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("reportable.hide.invalid", scope: "decidim.moderations.admin")
                redirect_to proposals_path
              end
            end
          end
        end
      end
    end
  end
end
