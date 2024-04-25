# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class ProposalsValuatorMailer < Decidim::ApplicationMailer
        include Decidim::TranslationsHelper
        include Decidim::SanitizeHelper
        include Decidim::ApplicationHelper
        include Decidim::TranslatableAttributes

        helper Decidim::ResourceHelper
        helper Decidim::TranslationsHelper
        helper Decidim::ApplicationHelper

        def notify_proposals_valuator(user, admin, proposals)
          @valuator_user = user
          @admin = admin
          @proposals = proposals
          @organization = user.organization

          with_user(user) do
            mail to: "#{user.name} <#{user.email}>",
                 subject: t("subject", scope: "decidim.reporting_proposals.admin.proposals_valuator_mailer.notify_proposals_valuator")
          end
        end
      end
    end
  end
end
