# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module AdminLog
      # This class holds the logic to present a `Decidim::ReportingProposals::TaxonomyEvaluator`
      # for the `AdminLog` log.
      #
      # Usage should be automatic and you should not need to call this class
      # directly, but here is an example:
      #
      #    action_log = Decidim::ActionLog.last
      #    view_helpers # => this comes from the views
      #    TaxonomyEvaluatorPresenter.new(action_log, view_helpers).present
      class TaxonomyEvaluatorPresenter < Decidim::Log::BasePresenter
        include Decidim::SanitizeHelper

        private

        def resource_presenter
          @resource_presenter ||= Decidim::ReportingProposals::Log::TaxonomyEvaluatorPresenter.new(action_log.resource, h, action_log.extra["resource"])
        end

        def diff_fields_mapping
          # the value is pre-resolved to the user name in #changeset
          { evaluator_role_id: :default }
        end

        def action_string
          case action
          when "create", "delete"
            "decidim.reporting_proposals.admin_log.taxonomy_evaluator.#{action}"
          else
            super
          end
        end

        def i18n_labels_scope
          "activemodel.attributes.taxonomy_evaluator.admin_log"
        end

        def diff_actions
          super + %w(create delete)
        end

        def i18n_params
          super.merge(taxonomy_name: decidim_escape_translated(action_log.extra["taxonomy_name"]))
        end

        # Replaces the raw role id with the evaluator user name, so the diff
        # survives the record deletion and cross-type id collisions.
        def changeset
          super.map do |field|
            next field unless field[:attribute_name] == :evaluator_role_id

            field.merge(
              new_value: field[:new_value] && evaluator_user_name,
              previous_value: field[:previous_value] && evaluator_user_name
            )
          end
        end

        def evaluator_user_name
          @evaluator_user_name ||= action_log.extra["evaluator_user_name"].presence || evaluator_role_from_version&.user&.name
        end

        # Fallback when the log extra lacks the user name: resolves the role
        # from the version payload (id + type).
        def evaluator_role_from_version
          changes = action_log.version&.changeset || {}
          role_id = Array(changes["evaluator_role_id"]).compact.last
          role_type = Array(changes["evaluator_role_type"]).compact.last
          return if role_id.blank? || role_type.blank?

          role_type.safe_constantize&.find_by(id: role_id)
        end
      end
    end
  end
end
