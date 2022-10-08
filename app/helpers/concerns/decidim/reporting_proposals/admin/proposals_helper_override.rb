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
            grace_period = days_unanswered(proposal)
            !grace_period.zero? &&
              proposal.state.blank? && (Time.current - grace_period.days).to_date > proposal.published_at
          end

          def evaluating_proposals_overdue?(proposal)
            grace_period = days_evaluating(proposal)
            !grace_period.zero? &&
              proposal.evaluating? && proposal.answered? &&
              (Time.current - grace_period.days).to_date > proposal.answered_at
          end

          def grace_period_unanswered?(proposal)
            !proposal.answered? && Time.current < last_day_to_answer(proposal)
          end

          def days_unanswered(proposal)
            return proposal.component.settings.unanswered_proposals_overdue.to_i if proposal.component&.settings

            Decidim::ReportingProposals.unanswered_proposals_overdue.to_i
          end

          def days_evaluating(proposal)
            return proposal.component.settings.evaluating_proposals_overdue.to_i if proposal.component&.settings

            Decidim::ReportingProposals.evaluating_proposals_overdue.to_i
          end

          def grace_period_evaluating?(proposal)
            proposal.evaluating? && Time.current < last_day_to_evaluate(proposal)
          end

          def last_day_to_answer(proposal)
            (proposal.published_at + days_unanswered(proposal).days).to_date
          end

          def last_day_to_evaluate(proposal)
            (proposal.answered_at + days_evaluating(proposal).days).to_date if proposal.answered?
          end

          def time_elapsed_to_answer(proposal)
            distance_of_time_in_words(proposal.answered_at, proposal.created_at,
                                      scope: "decidim.reporting_proposals.admin.time_elapsed.datetime.distance_in_words")
          end
        end
      end
    end
  end
end
