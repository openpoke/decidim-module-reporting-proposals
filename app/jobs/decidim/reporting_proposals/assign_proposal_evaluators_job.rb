module Decidim
  module ReportingProposals
    class AssignProposalEvaluatorsJob < ApplicationJob
      queue_as :default
      attr_reader :resource

      def perform(data)
        @resource = data[:resource]

        return if evaluator_roles.blank?

        unless data[:event_class] == "Decidim::Proposals::Admin::UpdateProposalCategoryEvent"
          return unless data[:extra][:participatory_space]
          return if data[:extra][:type] == "admin"
        end

        evaluator_roles.each do |evaluator_role|
          Decidim::Proposals::Admin::AssignProposalsToEvaluator.call(form(evaluator_role)) do
            on(:ok) do
              Rails.logger.info("Automatically assigned evaluator #{evaluator_role.user.name} to proposal ##{resource.id}")
            end
            on(:invalid) do
              Rails.logger.warn("Couldn't automatically assign evaluator #{evaluator_role.user.name} to proposal ##{resource.id}")
            end
          end
        end
      end

      def form(evaluator_role)
        Decidim::Proposals::Admin::EvaluationAssignmentForm.from_params(
          evaluator_role_ids: evaluator_role.id,
          proposal_ids: [resource.id]
        ).with_context(
          current_component: resource.component,
          current_user: resource.organization.users.first # first admin for the traceability
        )
      end

      # Obtener evaluadores del espacio participativo (sin usar category)
      def evaluator_roles
        @evaluator_roles ||= participatory_space
                             .user_roles(:evaluator)
                             .order_by_name
      end

      def participatory_space
        @participatory_space ||= resource.component.participatory_space
      end
    end
  end
end
