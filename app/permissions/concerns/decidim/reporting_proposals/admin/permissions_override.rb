# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module PermissionsOverride
        extend ActiveSupport::Concern

        included do

          private

          def valuator_can_unassign_valuator_from_proposals?
            can_unassign_valuator_from_proposals? if user == context.fetch(:valuator, nil)

            can_add_valuators?
          end

          def can_add_valuators?
            return unless permission_action.action == :assign_to_valuator && permission_action.subject == :proposals

            allow! if Decidim::ReportingProposals.allow_to_assign_other_valuators
          end
        end
      end
    end
  end
end
