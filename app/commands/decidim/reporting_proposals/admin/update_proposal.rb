# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # A command with all the business logic when a user updates a proposal.
      class UpdateProposal < Decidim::Proposals::Admin::UpdateProposal
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # proposal - the proposal to update.
        def initialize(form, proposal)
          @form = form
          @proposal = proposal
          @attached_to = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        #
        # Unlike the parent command, attachments are only appended (no cleanup),
        # so the existing ones survive; removal goes through `remove_photo`.
        def call
          return broadcast(:invalid) if form.invalid?

          if process_attachments?
            build_attachments
            return broadcast(:invalid) if attachments_invalid?
          end

          transaction do
            create_attachments(first_weight: first_attachment_weight) if process_attachments?
          end

          broadcast(:ok, proposal)
        end

        private

        # The form submits no keep ids, so the parent's photos.count could collide with an existing weight
        def first_attachment_weight
          proposal.attachments.maximum(:weight).to_i + 1
        end
      end
    end
  end
end
