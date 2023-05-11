# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module CloseMeetingFormOverride
      extend ActiveSupport::Concern

      included do
        alias_method :map_model_original, :map_model

        def map_model(model)
          map_model_original(model)
          self.proposal_ids += model.linked_resources(:reporting_proposals, "proposals_from_meeting").pluck(:id)
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
end
