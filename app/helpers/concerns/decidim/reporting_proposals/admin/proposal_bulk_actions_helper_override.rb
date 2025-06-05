# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module ProposalBulkActionsHelperOverride
        extend ActiveSupport::Concern

        included do
          def find_valuators_for_select(participatory_space, _current_user)
            valuator_roles = participatory_space.user_roles(:valuator).order_by_name
            valuators = Decidim::User.where(id: valuator_roles.pluck(:decidim_user_id)).to_a

            valuator_roles.map do |role|
              valuator = valuators.find { |user| user.id == role.decidim_user_id }
              [valuator.name, role.id]
            end
          end
        end
      end
    end
  end
end
