# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module CreateProjectOverride
      extend ActiveSupport::Concern

      included do
        def proposals
          @proposals ||= project.sibling_scope(:proposals).where(id: @form.proposal_ids) + project.sibling_scope(:reporting_proposals).where(id: form.proposal_ids)
        end
      end
    end
  end
end
