# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class ProposalPhotoForm < Decidim::Form
        include Decidim::AttachmentAttributes
        attachments_attribute :attachments

        validates :add_attachments, presence: true
        validate :attachments_are_images

        def current_component
          @current_component ||= context&.current_component
        end

        private

        def attachments_are_images
          return if add_attachments.compact_blank.all? { |entry| image_entry?(entry) }

          errors.add(:add_attachments, :only_images)
        end

        def image_entry?(entry)
          if entry.is_a?(Hash)
            id = entry[:id] || entry["id"]
            return Decidim::Attachment.find_by(id:).try(:photo?) || false if id.present?

            return image_blob?(entry[:file] || entry["file"])
          end

          content_type = entry.try(:content_type)
          return content_type.start_with?("image") if content_type.present?

          image_blob?(entry)
        end

        # Same predicate as Decidim::Attachment#photo?
        def image_blob?(signed_id)
          return false if signed_id.blank?

          ActiveStorage::Blob.find_signed(signed_id)&.image? || false
        rescue ActiveRecord::RecordNotFound
          false
        end
      end
    end
  end
end
