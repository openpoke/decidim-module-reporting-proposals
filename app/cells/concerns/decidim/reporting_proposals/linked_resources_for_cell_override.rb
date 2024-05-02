# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module LinkedResourcesForCellOverride
      extend ActiveSupport::Concern

      included do
        private

        def linked_resources
          @linked_resources ||= begin
            query = resource.linked_resources(type, link_name)
            query = query.or(resource.linked_resources(:reporting_proposals, link_name)) if type == :proposals

            query.group_by { |linked_resource| linked_resource.class.name }
          end
        end
      end
    end
  end
end
