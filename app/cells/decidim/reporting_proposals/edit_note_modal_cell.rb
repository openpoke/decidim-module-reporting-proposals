# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class EditNoteModalCell < Decidim::ViewModel
      include ActionView::Helpers::FormOptionsHelper
      include Decidim::ReportingProposals::AdminEngine.routes.url_helpers

      property :note, :proposal, :notes_form

      def show
        render if note
      end

      def modal_id
        options[:modal_id] || "editNoteModal"
      end

      def note
        @note ||= Decidim::Proposals::ProposalNote.find(params[:id])
      end

      def proposal
        @proposal ||= Decidim::Proposals::Proposal.find(note.decidim_proposal_id)
      end

      def notes_form
        @notes_form ||= Decidim::Proposals::Admin::ProposalNoteForm.from_params(params)
      end
    end
  end
end
