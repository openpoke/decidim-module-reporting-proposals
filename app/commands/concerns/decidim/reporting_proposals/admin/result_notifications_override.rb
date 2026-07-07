# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Notifies also the proposals linked from reporting proposals components
      # when a result progress is updated.
      module ResultNotificationsOverride
        extend ActiveSupport::Concern

        included do
          private

          def send_notifications
            all = result.linked_resources(:proposals, "included_proposals") + result.linked_resources(:reporting_proposals, "included_proposals")
            all.each do |proposal|
              Decidim::EventsManager.publish(
                event: "decidim.events.accountability.result_progress_updated",
                event_class: Decidim::Accountability::ResultProgressUpdatedEvent,
                resource: result,
                affected_users: proposal.notifiable_identities,
                followers: proposal.followers - proposal.notifiable_identities,
                extra: {
                  progress: result.progress,
                  proposal_id: proposal.id
                }
              )
            end
          end
        end
      end
    end
  end
end
