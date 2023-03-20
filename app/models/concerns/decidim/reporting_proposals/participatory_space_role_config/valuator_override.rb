# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ParticipatorySpaceRoleConfig
      module ValuatorOverride
        extend ActiveSupport::Concern

        included do
          alias_method :original_accepted_components, :accepted_components

          def accepted_components
            @accepted_components ||= original_accepted_components + [:reporting_proposals]
          end
        end
      end
    end
  end
end
