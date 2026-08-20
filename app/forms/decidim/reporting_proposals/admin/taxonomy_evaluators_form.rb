# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # A form object to update the automatic evaluators assigned to a
      # taxonomy within a participatory space.
      class TaxonomyEvaluatorsForm < Decidim::Form
        attribute :taxonomy_id, Integer
        attribute :evaluator_role_ids, Array[Integer]

        validates :taxonomy, presence: true
        validate :evaluator_roles_belong_to_participatory_space
        validate :same_participatory_space

        def evaluator_role_ids
          super.compact_blank
        end

        def taxonomy
          @taxonomy ||= Decidim::Taxonomy.for(current_organization).find_by(id: taxonomy_id)
        end

        def evaluator_roles
          @evaluator_roles ||= current_participatory_space
                               .user_roles(:evaluator)
                               .order_by_name
                               .where(id: evaluator_role_ids)
        end

        private

        def evaluator_roles_belong_to_participatory_space
          return if evaluator_role_ids.uniq.sort == evaluator_roles.pluck(:id).sort

          errors.add(:evaluator_role_ids, :invalid)
        end

        # Assembly user roles include the ancestor assemblies ones, so roles
        # are restricted to the ones defined in the space itself.
        def same_participatory_space
          return if evaluator_roles.for_space(current_participatory_space).size == evaluator_roles.size

          errors.add(:evaluator_role_ids, :invalid)
        end
      end
    end
  end
end
