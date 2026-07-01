# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class UpdateReportingProposal < Decidim::Proposals::UpdateProposal
      include Decidim::ReportingProposals::PhotoMethods

      def call
        return broadcast(:invalid) if invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        if process_photos?
          build_photos
          return broadcast(:invalid) if photos_invalid?
        end

        with_events(with_transaction: true) do
          if @proposal.draft?
            update_draft
          else
            update_proposal
          end

          cleanup_attachments_keeping_photos!

          create_attachments(first_weight: first_attachment_weight) if process_attachments?
          create_photos if process_photos?
        end

        broadcast(:ok, proposal)
      end

      private

      # Keep both form.attachments and form.photos; the upstream
      # attachment_cleanup! keeps only form.attachments and would drop kept photos.
      def cleanup_attachments_keeping_photos!
        keep = keep_ids | Array(@form.photos).map(&:id)
        attachments_attached_to.attachments.with_attached_file.each do |attachment|
          attachment.destroy! unless keep.include?(attachment.id)
        end
        attachments_attached_to.reload
        attachments_attached_to.instance_variable_set(:@attachments, nil)
        attachments_attached_to.instance_variable_set(:@photos, nil)
      end
    end
  end
end
