# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ParticipatorySpaceRoleConfig
      module ValuatorOverride
        extend ActiveSupport::Concern

        included do
          def accepted_components
            [:proposals, :reporting_proposals]
          end
        end
      end
    end
  end
end
