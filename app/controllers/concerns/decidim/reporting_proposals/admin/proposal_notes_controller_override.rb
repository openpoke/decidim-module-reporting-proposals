# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module ProposalNotesControllerOverride
        extend ActiveSupport::Concern

        included do
          helper_method :note

          def show
            @notes_form = form(Decidim::Proposals::Admin::ProposalNoteForm).from_model(note)
          end

          def edit
            enforce_permission_to :update, :note, proposal: proposal

            @notes_form = form(Decidim::Proposals::Admin::ProposalNoteForm).from_model(note)
          end

          def update
            enforce_permission_to :update, :note, proposal: proposal

            @notes_form = form(Decidim::Proposals::Admin::ProposalNoteForm).from_params(note_params)
            @notes_form.body = params[:note][:body]

            Decidim::ReportingProposals::Admin::UpdateProposalNote.call(@notes_form, note) do
              on(:ok) do
                flash[:notice] = I18n.t("proposal_notes.update.success", scope: "decidim.reporting_proposals.admin")
                redirect_to proposal_path(id: proposal.id)
              end

              on(:invalid) do
                flash.keep[:alert] = I18n.t("proposal_notes.update.invalid", scope: "decidim.reporting_proposals.admin")
                render :edit
              end
            end
          end

          private

          def note
            @note ||= Decidim::Proposals::ProposalNote.find(params[:id])
          end

          def note_params
            params.require(:proposal_note).permit(:body)
          end
        end
      end
    end
  end
end
