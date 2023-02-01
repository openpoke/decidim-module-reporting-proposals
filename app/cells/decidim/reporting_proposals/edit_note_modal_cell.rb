# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class EditNoteModalCell < Decidim::ViewModel
      include ActionView::Helpers::FormOptionsHelper
      include Decidim::ReportingProposals::AdminEngine.routes.url_helpers

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
    end
  end
end
