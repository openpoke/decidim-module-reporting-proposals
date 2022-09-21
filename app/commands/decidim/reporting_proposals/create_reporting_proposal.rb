# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class CreateReportingProposal < Decidim::Proposals::CreateProposal
      def create_proposal
        PaperTrail.request(enabled: false) do
          @proposal = Decidim.traceability.perform_action!(
            :create,
            Decidim::Proposals::Proposal,
            @current_user,
            visibility: "public-only"
          ) do
            proposal = Decidim::Proposals::Proposal.new(
              title: {
                I18n.locale => title_with_hashtags
              },
              body: {
                I18n.locale => body_with_hashtags
              },
              category: form.category,
              scope: form.scope,
              address: form.address,
              latitude: form.latitude,
              longitude: form.longitude,
              component: form.component
            )
            proposal.add_coauthor(@current_user, user_group: user_group)
            proposal.save!
            proposal
          end
        end
      end
    end
  end
end
