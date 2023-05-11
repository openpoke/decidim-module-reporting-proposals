# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module CloseMeetingOverride
      extend ActiveSupport::Concern

      included do
        def proposals
          @proposals ||= meeting.sibling_scope(:proposals).where(id: @form.proposal_ids) + meeting.sibling_scope(:reporting_proposals).where(id: form.proposal_ids)
        end
      end
    end
  end
end
