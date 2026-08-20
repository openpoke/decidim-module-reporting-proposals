# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module ProposalBulkActionsHelperOverride
        extend ActiveSupport::Concern

        included do
          def find_evaluators_for_select(participatory_space, _current_user)
            # assembly user roles include the ancestor assemblies ones, so a strict space check is needed
            evaluator_roles = participatory_space.user_roles(:evaluator).for_space(participatory_space).order_by_name
            evaluators = Decidim::User.where(id: evaluator_roles.pluck(:decidim_user_id)).to_a

            evaluator_roles.map do |role|
              evaluator = evaluators.find { |user| user.id == role.decidim_user_id }
              [evaluator.name, role.id]
            end
          end
        end
      end
    end
  end
end
