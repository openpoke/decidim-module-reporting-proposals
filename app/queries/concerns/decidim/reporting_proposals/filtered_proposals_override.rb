# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module FilteredProposalsOverride
      extend ActiveSupport::Concern

      included do
        def self.for(components, start_at = nil, end_at = nil, manifest_name = :proposals)
          filtered_components = components
          if manifest_name
            filtered_components = if components.respond_to?(:where)
                                    components.where(manifest_name:)
                                  else
                                    components.select { |component| component.manifest_name == manifest_name.to_s }
                                  end
          end
          new(filtered_components, start_at, end_at).query
        end
      end
    end
  end
end
