# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalsHelperOverride
        extend ActiveSupport::Concern

        included do
          # Helpers for overdue proposals
          include ActionView::Helpers::DateHelper

          def available_valuators_for_proposal(proposal, current_user)
            participatory_space = proposal.component.participatory_space

            all_roles = participatory_space.user_roles(:valuator).order_by_name
            assigned_ids = proposal.valuation_assignments.pluck(:valuator_role_id)

            available_roles = all_roles.reject do |role|
              role.decidim_user_id == current_user.id || assigned_ids.include?(role.id)
            end

            users_by_id = Decidim::User.where(id: available_roles.map(&:decidim_user_id)).index_by(&:id)

            available_roles.map do |role|
              user = users_by_id[role.decidim_user_id]
              [user.name, role.id]
            end
          end

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
