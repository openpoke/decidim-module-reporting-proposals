# frozen_string_literal: true

module Decidim
  module Admin
    # A custom mailer to mail Decidim users
    # that they have been hidden
    class HiddenResourceMailer < Decidim::ApplicationMailer
      include Decidim::TranslationsHelper
      include Decidim::SanitizeHelper
      include Decidim::ApplicationHelper
      include Decidim::TranslatableAttributes

      helper Decidim::ResourceHelper
      helper Decidim::TranslationsHelper
      helper Decidim::ApplicationHelper

      def notify_mail(resource, resource_authors, reason)
        @resource_authors = resource_authors
        @organization = resource.organization
        @resource = resource
        @reason = reason

        mail(to: resource_authors.pluck(:email).uniq,
             subject: I18n.t("decidim.admin.hidden_resource_mailer.notify_mail.subject"))
      end
    end
  end
end
