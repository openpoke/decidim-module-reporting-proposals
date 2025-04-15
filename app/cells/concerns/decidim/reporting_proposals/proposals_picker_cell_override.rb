# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalsPickerCellOverride
      extend ActiveSupport::Concern

      included do
        def proposals
          @proposals ||= begin
            proposals_query = Decidim.find_resource_manifest(:proposals).try(:resource_scope, component)
            reporting_proposals_query = Decidim.find_resource_manifest(:reporting_proposals).try(:resource_scope, component)
            (reporting_proposals_query ? proposals_query.or(reporting_proposals_query) : proposals_query)
              &.includes(:component)
              &.published
              &.not_hidden
              &.order(id: :asc)
          end
        end
      end
    end
  end
end
