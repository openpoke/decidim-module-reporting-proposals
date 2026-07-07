# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Base controller to manage the automatic evaluators assigned to the
      # taxonomies used by the proposals components of a participatory space.
      # Space specific controllers inherit from this one and include the
      # corresponding space admin concern.
      class TaxonomyEvaluatorsController < Decidim::Admin::ApplicationController
        include Decidim::TranslatableAttributes

        helper_method :collection, :tree_collection, :taxonomy, :taxonomy_depth,
                      :evaluators_for, :evaluators_for_select, :taxonomy_evaluators_router

        def index
          enforce_permission_to :update, :taxonomy_evaluator
        end

        def edit
          enforce_permission_to :update, :taxonomy_evaluator
          # prefilled with the evaluators in force (own or inherited);
          # saving the form always writes the taxonomy's own assignments
          @form = form(TaxonomyEvaluatorsForm).from_params(
            evaluator_role_ids: assignments_by_taxonomy[taxonomy].map(&:evaluator_role_id)
          )
          @form.taxonomy_id = taxonomy.id
        end

        def update
          enforce_permission_to :update, :taxonomy_evaluator
          @form = form(TaxonomyEvaluatorsForm).from_params(params)
          @form.taxonomy_id = taxonomy.id

          UpdateTaxonomyEvaluators.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("taxonomy_evaluators.update.success", scope: "decidim.reporting_proposals.admin")
              redirect_to taxonomy_evaluators_router.taxonomy_evaluators_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("taxonomy_evaluators.update.invalid", scope: "decidim.reporting_proposals.admin")
              render :edit, status: :unprocessable_entity
            end
          end
        end

        private

        def collection
          @collection ||= Decidim::Taxonomy.where(id: available_taxonomy_ids).load
        end

        # children keep the loaded collection's default_scope (weight) order:
        # weight is nullable, so re-sorting in Ruby is unsafe
        def tree_collection
          @tree_collection ||= begin
            children = collection.reject(&:root?).group_by(&:parent_id)
            ordered = []
            append = lambda do |node|
              ordered << node
              children.fetch(node.id, []).each(&append)
            end
            collection.select(&:root?).sort_by { |root| translated_attribute(root.name).downcase }.each(&append)
            ordered
          end
        end

        def taxonomy_depth(taxonomy)
          taxonomy.parent_ids.count
        end

        # assignments in force per taxonomy (own or nearest ancestor's) —
        # the same resolution the assignment job uses
        def assignments_by_taxonomy
          @assignments_by_taxonomy ||= TaxonomyEvaluator.assignments_for(collection, space_evaluator_roles)
        end

        # part_of lists the taxonomy itself plus all its ancestors up to the root
        def available_taxonomy_ids
          taxonomy_ids = proposals_components.flat_map(&:available_taxonomy_ids).uniq
          Decidim::Taxonomy.where(id: taxonomy_ids).pluck(:part_of).flatten.uniq
        end

        def proposals_components
          @proposals_components ||= current_participatory_space.components.where(manifest_name: %w(proposals reporting_proposals))
        end

        def taxonomy
          @taxonomy ||= collection.find(params[:id])
        end

        def evaluators_for(taxonomy)
          assignments_by_taxonomy[taxonomy].map(&:user)
        end

        # Assembly user roles include the ancestor assemblies ones, so the
        # scope is restricted to the roles defined in the space itself.
        def space_evaluator_roles
          @space_evaluator_roles ||= current_participatory_space.user_roles(:evaluator).for_space(current_participatory_space)
        end

        def evaluators_for_select
          space_evaluator_roles.order_by_name.map { |role| [role.user.name, role.id] }
        end

        def taxonomy_evaluators_router
          @taxonomy_evaluators_router ||= Decidim::EngineRouter.admin_proxy(current_participatory_space)
        end
      end
    end
  end
end
