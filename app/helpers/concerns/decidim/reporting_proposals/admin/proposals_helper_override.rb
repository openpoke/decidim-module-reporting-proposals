# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalsHelperOverride
        extend ActiveSupport::Concern

        included do
          # Helpers for overdue proposals

          def unanswered_proposals_overdue?(proposal)
            grace_period = Decidim::ReportingProposals.unanswered_proposals_overdue.to_i
            !grace_period.zero? &&
              proposal.state.blank? && (Time.current - grace_period.days).to_date > proposal.published_at
          end

          def evaluating_proposals_overdue?(proposal)
            grace_period = Decidim::ReportingProposals.evaluating_proposals_overdue.to_i
            !grace_period.zero? &&
              proposal.evaluating? && proposal.answered? &&
              (Time.current - grace_period.days).to_date > proposal.answered_at
          end

          def grace_period_unanswered?(proposal)
            !proposal.answered? && Time.current < last_day_to_answer(proposal)
          end

          def grace_period_evaluating?(proposal)
            proposal.evaluating? && Time.current < last_day_to_evaluate(proposal)
          end

          def last_day_to_answer(proposal)
            grace_period = Decidim::ReportingProposals.unanswered_proposals_overdue.to_i
            (proposal.published_at + grace_period.days).to_date
          end

          def last_day_to_evaluate(proposal)
            grace_period = Decidim::ReportingProposals.evaluating_proposals_overdue.to_i
            (proposal.answered_at + grace_period.days).to_date if proposal.answered?
          end
        end
      end
    end
  end
end
