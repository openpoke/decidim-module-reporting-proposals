# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalAnswerTemplatesControllerOverride
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
