# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module PermissionsOverride
        extend ActiveSupport::Concern

        included do
          # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
          def permissions
            # The public part needs to be implemented yet
            return permission_action if permission_action.scope != :admin

            # Valuators can only perform these actions
            if user_is_valuator?
              if valuator_assigned_to_proposal?
                can_create_proposal_note?
                can_create_proposal_answer?
                can_assign_valuator_to_proposal?
                allow! if action_is_show_on_proposal?
              elsif action_is_show_on_proposal?
                disallow!
              end

              valuator_can_unassign_valuator_from_proposals?
              can_export_proposals?

              return permission_action
            end

            if create_permission_action?
              can_create_proposal_note?
              can_create_proposal_from_admin?
              can_create_proposal_answer?
            end

            # Allow any admin user to view a proposal.
            allow! if action_is_show_on_proposal?

            # Admins can only edit official proposals if they are within the
            # time limit.
            allow! if permission_action.subject == :proposal && permission_action.action == :edit && admin_edition_is_available?

            # Every user allowed by the space can update the category of the proposal
            allow! if permission_action.subject == :proposal_category && permission_action.action == :update

            # Every user allowed by the space can update the scope of the proposal
            allow! if permission_action.subject == :proposal_scope && permission_action.action == :update

            # Every user allowed by the space can import proposals from another_component
            allow! if permission_action.subject == :proposals && permission_action.action == :import

            # Every user allowed by the space can export proposals
            can_export_proposals?

            # Every user allowed by the space can merge proposals to another component
            allow! if permission_action.subject == :proposals && permission_action.action == :merge

            # Every user allowed by the space can split proposals to another component
            allow! if permission_action.subject == :proposals && permission_action.action == :split

            # Every user allowed by the space can assign proposals to a valuator
            can_assign_valuator_to_proposal?

            # Every user allowed by the space can unassign a valuator from proposals
            can_unassign_valuator_from_proposals?

            # Only admin users can publish many answers at once
            toggle_allow(user.admin?) if permission_action.subject == :proposals && permission_action.action == :publish_answers

            if permission_action.subject == :participatory_texts && participatory_texts_are_enabled? && permission_action.action == :manage
              # Every user allowed by the space can manage (import, update and publish) participatory texts to proposals
              allow!
            end

            if permission_action.subject == :proposal_state
              if permission_action.action == :destroy
                toggle_allow(proposal_state.proposals.empty?)
              else
                allow!
              end
            end

            permission_action
          end
          # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

          private

          def action_is_show_on_proposal?
            permission_action.subject == :proposal && permission_action.action == :show
          end

          def valuator_can_unassign_valuator_from_proposals?
            can_unassign_valuator_from_proposals? if user == context.fetch(:valuator, nil)

            can_add_valuators?
          end

          def can_add_valuators?
            return unless permission_action.action == :assign_to_valuator && permission_action.subject == :proposals

            toggle_allow(Decidim::ReportingProposals.valuators_assign_other_valuators)
          end
        end
      end
    end
  end
end
