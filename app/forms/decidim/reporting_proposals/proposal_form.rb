# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class ProposalForm < Decidim::Proposals::ProposalForm
      attribute :address, String
      attribute :has_no_address, Boolean

      def has_address?
        return if has_no_address

        geocoding_enabled?
      end
    end
  end
end
