# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ResultFormOverride
        extend ActiveSupport::Concern

        included do
          def map_model(model)
            self.proposal_ids = model.linked_resources(:proposals, "included_proposals").pluck(:id) + model.linked_resources(:reporting_proposals, "included_proposals").pluck(:id)
            self.project_ids = model.linked_resources(:projects, "included_projects").pluck(:id)
            self.decidim_category_id = model.category.try(:id)
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
end
