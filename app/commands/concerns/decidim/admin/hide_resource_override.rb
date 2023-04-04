# frozen_string_literal: true

module Decidim
  module Admin
    module HideResourceOverride
      extend ActiveSupport::Concern

      included do
        def call
          return broadcast(:invalid) unless hideable?

          hide!

          send_hide_notification_to_author
          send_hide_email_to_author

          broadcast(:ok, @reportable)
        end

        private

        def send_hide_email_to_author
          Decidim::Admin::HiddenResourceMailer.notify_mail(
            @reportable, resource_authors, report_reasons
          ).deliver_later
        end

        def resource_authors
          @reportable.try(:authors) || [@reportable.try(:author)]
        end
      end
    end
  end
end
