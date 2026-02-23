# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module HasResultCommandOverride
        extend ActiveSupport::Concern

        included do
          def proposals
            @proposals ||= resource.sibling_scope(:proposals).where(id: form.proposal_ids) + resource.sibling_scope(:reporting_proposals).where(id: form.proposal_ids)
          end

          def link_proposals
            resource.link_resources(proposals, "included_proposals")
          end
        end
      end
    end
  end
end
