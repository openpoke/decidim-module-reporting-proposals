# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module CloseMeetingFormOverride
      extend ActiveSupport::Concern
      include Decidim::ReportingProposals::LinkedProposalsForFormOverride

      def proposals_link_name
        "proposals_from_meeting"
      end
    end
  end
end
