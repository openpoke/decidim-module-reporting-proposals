# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class ProposalPhotoForm < Decidim::Proposals::Admin::ProposalForm
        include Decidim::AttachmentAttributes
        attribute :attachment, AttachmentForm
        attachments_attribute :photos

        private

        def notify_missing_attachment_if_errored
          errors.add(:add_photos, :needs_to_be_reattached) if errors.any? && add_photos.present?
        end
      end
    end
  end
end
