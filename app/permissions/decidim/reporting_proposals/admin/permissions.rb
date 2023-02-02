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
          edit_proposal_note?
          super
        end

        private

        def current_organization
          context[:proposal].try(:organization) || context[:current_organization]
        end

        def component_settings
          context[:component_settings] || component.try(:settings)
        end

        def component
          context[:proposal].try(:component) || context[:current_component]
        end

        def user_author_note?
          context[:proposal_note].author == user
        end

        def hide_content_action?
          return unless permission_action.action == :hide_proposal && permission_action.subject == :proposals

          toggle_allow((admin_hide_proposals_enabled? && user_allowed_or_assigned?) || user_administrator?)
        end

        def edit_photos_action?
          return unless permission_action.action == :edit_photos && permission_action.subject == :proposals

          toggle_allow(admin_proposal_photo_editing_enabled? && (user_allowed_or_assigned? || user_administrator?))
        end

        def edit_proposal_note?
          return unless permission_action.action == :edit_note && permission_action.subject == :proposal_note

          toggle_allow(user_author_note?)
          # allow! if user_author_note?
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

        def user_administrator?
          process = Decidim::ParticipatoryProcess.where(organization: context[:proposal].try(:organization))

          admin = Decidim::User.where(id: Decidim::ParticipatoryProcessUserRole
                                            .where(participatory_process: process, role: :admin)
                                            .select(user.id))

          admin.exists? ? user : nil
        end
      end
    end
  end
end
