# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user
          return permission_action unless user.admin?
          return permission_action unless same_organization?

          hide_content_action?

          permission_action
        end

        def same_organization?
          return if context[:resource].try(:organization) != user.organization
          return if context[:current_organization] != user.organization

          true
        end

        def hide_content_action?
          return unless permission_action.action == :hide &&
                        permission_action.subject == :resource

          allow!
        end
      end
    end
  end
end
