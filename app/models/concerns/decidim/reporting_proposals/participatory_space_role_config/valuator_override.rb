# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ParticipatorySpaceRoleConfig
      module ValuatorOverride
        extend ActiveSupport::Concern

        included do
          # it is important to ensure that the aliased method name is unique in case of other modules are doing the same
          alias_method :decidim_reporting_proposals_original_accepted_components, :accepted_components

          def accepted_components
            decidim_reporting_proposals_original_accepted_components + [:reporting_proposals]
          end
        end
      end
    end
  end
end
