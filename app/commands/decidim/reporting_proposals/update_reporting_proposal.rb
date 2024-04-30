# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class UpdateReportingProposal < Decidim::Proposals::UpdateProposal
      include ::Decidim::Proposals::GalleryMethods

      def call
        return broadcast(:invalid) if invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        if process_gallery?
          build_gallery
          return broadcast(:invalid) if gallery_invalid?
        end

        with_events(with_transaction: true) do
          if @proposal.draft?
            update_draft
          else
            update_proposal
          end

          document_cleanup!(include_all_attachments: true)

          create_attachments(first_weight: first_attachment_weight) if process_attachments?
          create_gallery if process_gallery?
        end

        broadcast(:ok, proposal)
      end
    end
  end
end
