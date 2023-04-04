# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module PublishProposalOverride
      extend ActiveSupport::Concern

      included do
        def call
          return broadcast(:invalid) unless @proposal.authored_by?(@current_user)

          transaction do
            publish_proposal
            increment_scores
            send_notification
            send_notification_to_participatory_space
            send_notification_to_admins
          end

          broadcast(:ok, @proposal)
        end

        private

        def send_notification_to_participatory_space
          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_published",
            event_class: Decidim::Proposals::PublishProposalEvent,
            resource: @proposal,
            followers: @proposal.participatory_space.followers - coauthors_followers - admins_followers,
            extra: {
              participatory_space: true
            }
          )
        end

        def send_notification_to_admins
          return if admins_followers.empty?

          Decidim::EventsManager.publish(
            event: "decidim.events.proposals.proposal_published",
            event_class: Decidim::Proposals::PublishProposalEvent,
            resource: @proposal,
            followers: admins_followers,
            extra: {
              type: "admin",
              participatory_space: true
            }
          )
        end

        def admins_followers
          @proposal.followers.where(admin: true).uniq
        end
      end
    end
  end
end
