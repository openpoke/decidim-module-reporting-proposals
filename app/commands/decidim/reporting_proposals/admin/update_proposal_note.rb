# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # A command with all the business logic when a user updates a proposal note.
      class UpdateProposalNote < Decidim::Command
        include Decidim::Proposals::Admin::ProposalNotesMethods

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # note - the proposal_note to update.
        def initialize(form, note)
          @form = form
          @note = note
        end

        def call
          return broadcast(:invalid) if form.invalid?

          update_proposal_note

          broadcast(:ok, note)
        end

        private

        attr_reader :form, :note

        def update_proposal_note
          Decidim.traceability.update!(note, form.current_user, { body: rewritten_body }, resource: { title: note.proposal.title })
        end
      end
    end
  end
end
