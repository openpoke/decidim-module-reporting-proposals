# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class AssignProposalValuatorsJob < ApplicationJob
      queue_as :default
      attr_reader :resource

      def perform(data)
        @resource = data[:resource]

        return if valuator_roles.blank?

        unless data[:event_class] == "Decidim::Proposals::Admin::UpdateProposalCategoryEvent"
          return unless data[:extra][:participatory_space]
          return if data[:extra][:type] == "admin"
        end

        valuator_roles.each do |valuator_role|
          Decidim::Proposals::Admin::AssignProposalsToValuator.call(form(valuator_role)) do
            on(:ok) do
              Rails.logger.info("Automatically assigned valuator #{valuator_role.user.name} to proposal ##{resource.id}")
            end
            on(:invalid) do
              Rails.logger.warn("Couldn't automatically assign valuator #{valuator_role.user.name} to proposal ##{resource.id}")
            end
          end
        end
      end

      def form(valuator_role)
        Decidim::Proposals::Admin::ValuationAssignmentForm.from_params(
          id: valuator_role.id,
          proposal_ids: [resource.id]
        ).with_context(
          current_component: resource.component,
          current_user: resource.organization.users.first # first admin for the traceability
        )
      end

      # get valuators from categories
      def valuator_roles
        @valuator_roles ||= category.valuator_roles
      end

      def category
        @category ||= resource.category
      end
    end
  end
end
