# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module CreateResultOverride
        extend ActiveSupport::Concern

        included do
          def proposals
            @proposals ||= result.sibling_scope(:proposals).where(id: @form.proposal_ids) + result.sibling_scope(:reporting_proposals).where(id: @form.proposal_ids)
          end
        end
      end
    end
  end
end
