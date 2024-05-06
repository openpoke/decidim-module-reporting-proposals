# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class ProposalForm < Decidim::Proposals::ProposalForm
      attribute :address, String
      attribute :has_no_address, Boolean
      attribute :has_no_image, Boolean

      attachments_attribute :photos

      validates :add_photos, presence: true, if: ->(form) { form.has_camera? && form.photos.blank? }

      # Set the has no address
      def map_model(model)
        super(model)

        self.has_no_address = true if model.address.blank?
        self.has_no_image = true if model.photo.blank?
      end

      def has_address?
        return if has_no_address

        geocoding_enabled?
      end

      def has_camera?
        return if has_no_image

        current_component.settings.attachments_allowed?
      end
    end
  end
end
