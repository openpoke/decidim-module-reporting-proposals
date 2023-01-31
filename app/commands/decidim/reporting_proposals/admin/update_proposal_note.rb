# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # A command with all the business logic when a user updates a proposal note.
      class UpdateProposalNote < Rectify::Command
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # proposal_note - the proposal_note to update.
        def initialize(notes_form, proposal_note)
          @notes_form = notes_form
          @proposal_note = proposal_note
        end

        def call
          return broadcast(:invalid) if form.invalid?

          update_proposal_note

          broadcast(:ok, proposal_note)
        end

        private

        attr_reader :notes_form, :proposal_note, :proposal

        def update_proposal_note
          @proposal_note = Decidim.traceability.update!(
            ProposalNote,
            notes_form.current_user,
            {
              body: form.body,
              proposal: proposal,
              author: form.current_user
            },
            resource: {
              title: proposal.title
            }
          )
        end
      end
    end
  end
end
