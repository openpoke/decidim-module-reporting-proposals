# frozen_string_literal: true

module Decidim
  module Proposals
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
            ProposalsValuatorMailer.notify_proposals_valuator(form.valuator_role.user, form.current_user, form.proposals).deliver_later
          end
        end
      end
    end
  end
end
