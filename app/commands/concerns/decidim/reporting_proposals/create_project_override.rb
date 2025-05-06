# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module CreateProjectOverride
      extend ActiveSupport::Concern

      included do
        def proposals
          @proposals ||= resource.sibling_scope(:proposals).where(id: @form.proposal_ids) + resource.sibling_scope(:reporting_proposals).where(id: form.proposal_ids)
        end
      end
    end
  end
end
