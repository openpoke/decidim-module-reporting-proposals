# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        return Decidim::ReportingProposals::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        geocoding_action?

        permission_action
      end

      def geocoding_action?
        return unless permission_action.subject == :geocoding

        allow!
      end
    end
  end
end
