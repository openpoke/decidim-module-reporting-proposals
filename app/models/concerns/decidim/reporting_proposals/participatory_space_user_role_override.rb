# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ParticipatorySpaceUserRoleOverride
      extend ActiveSupport::Concern

      included do
        has_many :taxonomy_evaluators,
                 class_name: "Decidim::ReportingProposals::TaxonomyEvaluator",
                 as: :evaluator_role,
                 dependent: :destroy

        # Decidim does not clean EvaluationAssignment records when a space role
        # is removed (https://github.com/decidim/decidim/issues/10353 is closed,
        # but 0.31 still has no dependent cleanup), so they are removed here.
        has_many :proposal_evaluation_assignments,
                 class_name: "Decidim::Proposals::EvaluationAssignment",
                 as: :evaluator_role,
                 dependent: :destroy
      end
    end
  end
end
