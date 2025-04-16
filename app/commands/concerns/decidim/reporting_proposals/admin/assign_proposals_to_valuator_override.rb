# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module AssignProposalsToValuatorOverride
        extend ActiveSupport::Concern

        included do
          def call
            return broadcast(:invalid) unless form.valid?

            assign_proposals
            send_email

            broadcast(:ok)
          rescue ActiveRecord::RecordInvalid
            broadcast(:invalid)
          end

          private

          def send_email
            form.valuator_roles.each do |role|
              ProposalsValuatorMailer.notify_proposals_valuator(role.user, form.current_user, form.proposals).deliver_later
            end
          end
        end
      end
    end
  end
end
