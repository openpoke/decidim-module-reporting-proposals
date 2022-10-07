# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class Permissions < Decidim::Proposals::Admin::Permissions
        def permissions
          return permission_action if permission_action.scope != :admin
          return permission_action unless user
          return permission_action if current_organization != user.organization

          hide_content_action?
          edit_photos_action?
          super
        end

        def current_organization
          context[:proposal].try(:organization) || context[:current_organization]
        end

        def component_settings
          context[:component_settings] || component.try(:settings)
        end

        def component
          context[:proposal].try(:component) || context[:current_component]
        end

        def hide_content_action?
          return unless permission_action.action == :hide_proposal && permission_action.subject == :proposals

          toggle_allow(admin_hide_proposals_enabled? && user_allowed_or_assigned?)
        end

        def edit_photos_action?
          return unless permission_action.action == :edit_photos && permission_action.subject == :proposals

          toggle_allow(admin_proposal_photo_editing_enabled? && user_allowed_or_assigned?)
        end

        def admin_proposal_photo_editing_enabled?
          Decidim::ReportingProposals.allow_proposal_photo_editing.present? &&
            component_settings.try(:proposal_photo_editing_enabled)
        end

        def admin_hide_proposals_enabled?
          Decidim::ReportingProposals.allow_admins_to_hide_proposals.present?
        end

        def user_allowed_or_assigned?
          user.admin? || (user_is_valuator? && valuator_assigned_to_proposal?)
        end
      end
    end
  end
end
