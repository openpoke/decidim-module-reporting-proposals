# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class ProposalNotesController < Admin::ApplicationController
        helper_method :note

        def update
          enforce_permission_to :edit_note, :proposal_note, proposal_note: note
          @notes_form = form(Decidim::Proposals::Admin::ProposalNoteForm).from_params(params)

          Decidim::ReportingProposals::Admin::UpdateProposalNote.call(@notes_form, note) do
            on(:ok) do
              flash[:notice] = I18n.t("proposal_notes.update.success", scope: "decidim.reporting_proposals.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("proposal_notes.update.invalid", scope: "decidim.reporting_proposals.admin")
            end
            redirect_back(fallback_location: decidim_admin.root_path)
          end
        end

        private

        def note
          @note ||= Decidim::Proposals::ProposalNote.find(params[:id])
        end
      end
    end
  end
end
