# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class AssignProposalValuatorsJob < ApplicationJob
      queue_as :default
      attr_reader :resource

      def perform(data)
        @resource = data[:resource]

        return unless valuator_roles

        valuator_roles.each do |valuator_role|
          Decidim::Proposals::AssignProposalsToValuator.call(form(valuator_role))
        end
      end

      def form(valuator_role)
        Decidim::Proposals::ValuationAssignmentForm.from_params(
          id: valuator_role.id,
          proposals_ids: [resource.id]
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
        @category ||= proposal.category
      end
    end
  end
end
