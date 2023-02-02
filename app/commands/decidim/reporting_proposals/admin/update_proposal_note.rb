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
        def initialize(notes_form, note)
          @notes_form = notes_form
          @note = note
        end

        def call
          return broadcast(:invalid) if form.invalid?

          update_proposal_note

          broadcast(:ok, note)
        end

        private

        attr_reader :notes_form, :note, :proposal

        def update_proposal_note
          note.body = notes_form.body
          note.save!
        end
      end
    end
  end
end
