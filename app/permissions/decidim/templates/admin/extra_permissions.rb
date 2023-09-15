# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      class ExtraPermissions < Decidim::DefaultPermissions
        # this should go to the standard templates/permissions class but to avoid hacking it we put it here
        # to be removed when proposal templates is accepted into core
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user
          return permission_action if context[:current_organization] != user.organization

          # return permission_action if context[:current_organization] != user.organization
          allow! if user_has_a_role? && (permission_action.subject == :template && permission_action.action == :read)

          super
        end

        private

        def participatory_space
          @participatory_space ||= context[:proposal].try(:participatory_space)
        end

        def user_roles
          @user_roles ||= participatory_space.try(:user_roles)
        end

        def user_has_a_role?
          return unless user_roles

          user_roles.exists?(user: user)
        end
      end
    end
  end
end
