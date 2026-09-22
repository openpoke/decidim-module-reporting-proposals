# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # A command with all the business logic to update the automatic
      # evaluators assigned to a taxonomy within a participatory space.
      class UpdateTaxonomyEvaluators < Decidim::Command
        delegate :current_user, to: :form

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless form.valid?

          sync_taxonomy_evaluators
          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
          broadcast(:invalid)
        end

        private

        attr_reader :form

        def sync_taxonomy_evaluators
          transaction do
            current_evaluators.where(evaluator_role_id: removed_evaluator_role_ids).each do |taxonomy_evaluator|
              remove_taxonomy_evaluator(taxonomy_evaluator)
            end

            form.evaluator_roles.where(id: added_evaluator_role_ids).each do |evaluator_role|
              create_taxonomy_evaluator(evaluator_role)
            end
          end
        end

        def create_taxonomy_evaluator(evaluator_role)
          Decidim.traceability.create!(
            TaxonomyEvaluator,
            current_user,
            { taxonomy: form.taxonomy, evaluator_role: },
            evaluator_user_name: evaluator_role.user&.name
          )
        end

        # The extra info keeps the log entry renderable after the record and
        # its role are gone.
        def remove_taxonomy_evaluator(taxonomy_evaluator)
          Decidim.traceability.perform_action!(
            :delete,
            taxonomy_evaluator,
            current_user,
            taxonomy_name: form.taxonomy.name,
            evaluator_user_name: taxonomy_evaluator.evaluator_role&.user&.name
          ) do
            taxonomy_evaluator.destroy!
          end
        end

        def removed_evaluator_role_ids
          @removed_evaluator_role_ids ||= current_evaluator_role_ids - selected_evaluator_role_ids
        end

        def added_evaluator_role_ids
          @added_evaluator_role_ids ||= selected_evaluator_role_ids - current_evaluator_role_ids
        end

        # Assembly user roles include the ancestor assemblies ones, so the
        # scope is restricted to the roles defined in the space itself.
        def current_evaluators
          @current_evaluators ||= TaxonomyEvaluator.where(
            taxonomy: form.taxonomy,
            evaluator_role: form.current_participatory_space.user_roles(:evaluator).for_space(form.current_participatory_space)
          )
        end

        def current_evaluator_role_ids
          @current_evaluator_role_ids ||= current_evaluators.pluck(:evaluator_role_id)
        end

        def selected_evaluator_role_ids
          @selected_evaluator_role_ids ||= form.evaluator_roles.pluck(:id)
        end
      end
    end
  end
end
