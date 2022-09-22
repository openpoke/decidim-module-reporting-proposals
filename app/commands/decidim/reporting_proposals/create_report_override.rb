# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module CreateReportOverride
      extend ActiveSupport::Concern

      included do
        def send_report_notification_to_moderators
          participatory_space_moderators.each do |moderator|
            next unless moderator.email_on_moderations

            ReportedMailer.report(moderator, @report).deliver_later unless @current_user.admin?
          end
        end
      end
    end
  end
end
