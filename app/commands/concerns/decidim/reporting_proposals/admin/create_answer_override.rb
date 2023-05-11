# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module CreateAnswerOverride
        extend ActiveSupport::Concern

        included do
          def proposals
            @proposals ||= answer.sibling_scope(:proposals).where(id: @form.proposal_ids) + answer.sibling_scope(:reporting_proposals).where(id: @form.proposal_ids)
          end
        end
      end
    end
  end
end
