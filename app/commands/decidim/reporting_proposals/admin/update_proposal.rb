# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # A command with all the business logic when a user updates a proposal.
      class UpdateProposal < Decidim::Proposals::Admin::UpdateProposal
        # Public: Initializes the command.
        #
        # form         - A form object with the params.
        # proposal - the proposal to update.
        def initialize(form, proposal)
          @form = form
          @proposal = proposal
          @attached_to = proposal
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the proposal.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          if process_gallery?
            build_gallery
            return broadcast(:invalid) if gallery_invalid?
          end

          transaction do
            create_gallery if process_gallery?
            photo_cleanup!
          end

          broadcast(:ok, proposal)
        end

        private

        attr_reader :form, :proposal, :gallery
      end
    end
  end
end
