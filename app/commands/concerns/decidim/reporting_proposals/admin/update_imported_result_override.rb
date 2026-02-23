# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module UpdateImportedResultOverride
        extend ActiveSupport::Concern

        included do
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
