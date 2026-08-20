# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ParticipatorySpacePermissionsOverride
      def permissions
        super

        allow! if taxonomy_evaluator_action? && can_manage_taxonomy_evaluators?

        permission_action
      end

      private

      def taxonomy_evaluator_action?
        permission_action.scope == :admin &&
          permission_action.subject == :taxonomy_evaluator &&
          permission_action.action == :update
      end

      def can_manage_taxonomy_evaluators?
        return false unless user && current_participatory_space

        return true if user.admin? && user.organization == current_participatory_space.organization

        # assembly user_roles include the ancestor assemblies ones on purpose:
        # upstream grants parent assembly admins access to child assemblies
        current_participatory_space.user_roles(:admin).exists?(user:)
      end

      def current_participatory_space
        @current_participatory_space ||= context.fetch(:current_participatory_space, nil)
      end
    end
  end
end
