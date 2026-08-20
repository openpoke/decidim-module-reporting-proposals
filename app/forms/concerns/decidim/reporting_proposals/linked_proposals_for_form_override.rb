# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Makes forms linking proposals aware of reporting proposals components:
    # includers define +proposals_link_name+ with the resource link name.
    module LinkedProposalsForFormOverride
      def map_model(model)
        super
        self.proposal_ids += model.linked_resources(:reporting_proposals, proposals_link_name).pluck(:id)
      end

      def proposals
        @proposals ||= begin
          proposals_query = Decidim.find_resource_manifest(:proposals).try(:resource_scope, current_component)
          reporting_proposals_query = Decidim.find_resource_manifest(:reporting_proposals).try(:resource_scope, current_component)
          (reporting_proposals_query ? proposals_query.or(reporting_proposals_query) : proposals_query)
            &.where(id: proposal_ids)
            &.order(title: :asc)
        end
      end
    end
  end
end
