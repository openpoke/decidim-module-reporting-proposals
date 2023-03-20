# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ParticipatorySpaceRoleConfig
      module ValuatorOverride
        extend ActiveSupport::Concern

        included do
          # store the current value class-wide so it is compatible with other module adding accepted_components elements
          @@currently_accepted_components = self.new(nil).accepted_components

          def accepted_components
            @accepted_components ||= @@currently_accepted_components + [:reporting_proposals]
          end
        end
      end
    end
  end
end
