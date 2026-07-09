# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ParticipatorySpaceRoleConfig
      module EvaluatorOverride
        def accepted_components
          super + [:reporting_proposals]
        end
      end
    end
  end
end
