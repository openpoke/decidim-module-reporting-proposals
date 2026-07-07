# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module MapIncludedProposalsForFormOverride
      extend ActiveSupport::Concern
      include Decidim::ReportingProposals::LinkedProposalsForFormOverride

      def proposals_link_name
        "included_proposals"
      end
    end
  end
end
