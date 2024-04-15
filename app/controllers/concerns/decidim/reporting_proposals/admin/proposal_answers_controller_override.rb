# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalAnswersControllerOverride
        extend ActiveSupport::Concern

        included do
          helper Decidim::Proposals::Admin::ProposalBulkActionsHelper
          def update
            enforce_permission_to(:create, :proposal_answer, proposal:)

            @notes_form = form(Decidim::Proposals::Admin::ProposalNoteForm).instance
            @answer_form = form(Decidim::Proposals::Admin::ProposalAnswerForm).from_params(params)
            @photo_form = form(Decidim::ReportingProposals::Admin::ProposalPhotoForm).instance

            Decidim::Proposals::Admin::AnswerProposal.call(@answer_form, proposal) do
              on(:ok) do
                flash[:notice] = I18n.t("proposals.answer.success", scope: "decidim.proposals.admin")
                redirect_to proposals_path
              end

              on(:invalid) do
                flash.keep[:alert] = I18n.t("proposals.answer.invalid", scope: "decidim.proposals.admin")
                render template: "decidim/proposals/admin/proposals/show"
              end
            end
          end
        end
      end
    end
  end
end
