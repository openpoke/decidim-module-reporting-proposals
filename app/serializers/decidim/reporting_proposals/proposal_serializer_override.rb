# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ProposalSerializerOverride
      extend ActiveSupport::Concern

      included do
        include ActionView::Helpers::DateHelper
        include Decidim::Proposals::Admin::ProposalsHelper

        def serialize
          {
            id: proposal.id,
            taxonomies:,
            participatory_space: {
              id: proposal.participatory_space.id,
              url: Decidim::ResourceLocatorPresenter.new(proposal.participatory_space).url
            },
            component: { id: component.id },
            title: proposal.title,
            body: proposal.body,
            address: proposal.address,
            latitude: proposal.latitude,
            longitude: proposal.longitude,
            state: proposal.state.to_s,
            state_published_at: proposal.state_published_at,
            reference: proposal.reference,
            answer: ensure_translatable(proposal.answer),
            answer_time:,
            votes: proposal.proposal_votes_count,
            likes: {
              total_count: proposal.likes.size,
              user_likes:
            },
            comments: proposal.comments_count,
            attachments: proposal.attachments.size,
            follows_count: proposal.follows_count,
            published_at: proposal.published_at,
            url:,
            meeting_urls: meetings,
            related_proposals:,
            is_amend: proposal.emendation?,
            original_proposal: {
              title: proposal&.amendable&.title,
              url: original_proposal_url
            }
          }
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
