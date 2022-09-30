# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class ProposalForm < Decidim::Proposals::ProposalForm
      attribute :address, String
      attribute :has_no_address, Boolean
      attribute :has_no_image, Boolean

      validates :add_photos, presence: true, if: ->(form) { form.has_camera? }

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
