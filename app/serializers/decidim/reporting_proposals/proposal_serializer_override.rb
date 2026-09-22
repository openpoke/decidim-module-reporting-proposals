# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ProposalSerializerOverride
      extend ActiveSupport::Concern

      included do
        include ActionView::Helpers::DateHelper
        include Decidim::Proposals::Admin::ProposalsHelper

        alias_method :reporting_proposals_original_serialize, :serialize unless method_defined?(:reporting_proposals_original_serialize)

        def serialize
          reporting_proposals_original_serialize.merge(answer_time:)
        end

        def answer_time
          if unanswered_proposals_overdue?(proposal)
            time_ago_in_words(last_day_to_answer(proposal),
                              scope: "decidim.reporting_proposals.admin.answer_overdue.datetime.distance_in_words")
          elsif evaluating_proposals_overdue?(proposal)
            time_ago_in_words(last_day_to_evaluate(proposal),
                              scope: "decidim.reporting_proposals.admin.answer_overdue.datetime.distance_in_words")
          elsif grace_period_unanswered?(proposal)
            time_ago_in_words(last_day_to_answer(proposal),
                              scope: "decidim.reporting_proposals.admin.answer_pending.datetime.distance_in_words")
          elsif grace_period_evaluating?(proposal)
            time_ago_in_words(last_day_to_evaluate(proposal),
                              scope: "decidim.reporting_proposals.admin.evaluate_pending.datetime.distance_in_words")
          elsif proposal.accepted? || proposal.rejected?
            "#{I18n.t("decidim.reporting_proposals.admin.resolution_time")}: #{time_elapsed_to_answer(proposal)}"
          end
        end
      end
    end
  end
end
