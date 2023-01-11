# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module UpdateProposalCategoryOverride
        extend ActiveSupport::Concern

        included do
          private

          def notify_author(proposal)
            Decidim::EventsManager.publish(
              event: "decidim.events.proposals.proposal_update_category",
              event_class: Decidim::Proposals::Admin::UpdateProposalCategoryEvent,
              resource: proposal,
              affected_users: proposal.notifiable_identities,
              extra: {
                participatory_space: true
              }
            )
          end
        end
      end
    end
  end
end
