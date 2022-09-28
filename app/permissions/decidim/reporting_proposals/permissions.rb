# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        return Decidim::ReportingProposals::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        editor_image_action?

        permission_action
      end
    end
  end
end
