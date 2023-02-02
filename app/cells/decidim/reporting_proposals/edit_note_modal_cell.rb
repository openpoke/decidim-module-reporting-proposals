# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class EditNoteModalCell < Decidim::ViewModel
      include ActionView::Helpers::FormOptionsHelper

      def show
        render if note
      end

      def note
        model
      end

      def proposal
        Decidim::Proposals::Proposal.find(model.decidim_proposal_id)
      end

      def note_body
        model.body
      end

      def modal_id
        options[:modal_id] || "editNoteModal"
      end

      def notes_form
        @notes_form = Decidim::Proposals::Admin::ProposalNoteForm.from_model(note)
      end

      def note_path
        Decidim::ReportingProposals::AdminEngine.routes.url_helpers.proposal_note_path(proposal_id: proposal.id, id: note)
      end
    end
  end
end
