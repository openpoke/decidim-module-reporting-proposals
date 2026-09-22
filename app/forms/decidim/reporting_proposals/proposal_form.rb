# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class ProposalForm < Decidim::Proposals::ProposalForm
      attribute :address, String
      attribute :has_no_address, Boolean
      attribute :has_no_attachments, Boolean

      validates :attachments, presence: true, if: ->(form) { form.attachments_required? && form.add_attachments.compact_blank.blank? }

      def map_model(model)
        super

        self.has_no_address = true if model.address.blank?
        self.has_no_attachments = true if model.attachments.blank?
      end

      def has_address?
        return false if has_no_address

        geocoding_enabled?
      end

      def attachments_required?
        return false if has_no_attachments

        current_component.settings.attachments_allowed?
      end
    end
  end
end
