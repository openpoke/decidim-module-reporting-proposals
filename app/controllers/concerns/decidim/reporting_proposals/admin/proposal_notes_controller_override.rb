# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module ProposalNotesControllerOverride
        extend ActiveSupport::Concern

        included do
          helper_method :proposal_note

          def edit
            enforce_permission_to :update, :proposal_note, proposal: proposal

            @notes_form = form(ProposalNoteForm).from_model(proposal_note)
          end

          def update
            enforce_permission_to :update, :proposal_note, proposal: proposal

            @notes_form = form(ProposalNoteForm).from_params(params)

            Decidim::ReportingProposals::Admin::UpdateProposalNote.call(@notes_form, proposal_note) do
              on(:ok) do
                flash[:notice] = I18n.t("proposal_notes.update.success", scope: "decidim.reporting_proposals.admin")
                redirect_to proposal_path(id: proposal.id)
              end

              on(:invalid) do
                flash.keep[:alert] = I18n.t("proposal_notes.update.invalid", scope: "decidim.reporting_proposals.admin")
                redirect_to proposal_path(id: proposal.id)
              end
            end
          end

          private

          def proposal_note
            @proposal_note ||= Decidim::Proposals::ProposalNote.find(params[:id])
          end
        end
      end
    end
  end
end
