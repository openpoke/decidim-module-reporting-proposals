# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Included into the participatory space admin permission classes
    # (Decidim::ParticipatoryProcesses::Permissions, Decidim::Assemblies::Permissions)
    # to grant space admins access to the taxonomy evaluators management pages
    # (index/edit/update share the :update action).
    module ParticipatorySpacePermissionsOverride
      extend ActiveSupport::Concern

      included do
        alias_method :reporting_proposals_original_permissions, :permissions

        def permissions
          reporting_proposals_original_permissions

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
          space = context[:current_participatory_space]
          return false unless user && space

          return true if user.admin? && user.organization == space.organization

          # assembly user_roles include the ancestor assemblies ones on purpose:
          # upstream grants parent assembly admins access to child assemblies
          space.user_roles(:admin).exists?(user:)
        end
      end
    end
  end
end
