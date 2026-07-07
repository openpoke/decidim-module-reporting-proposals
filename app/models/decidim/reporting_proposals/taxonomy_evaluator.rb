# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Links a taxonomy and an Evaluator user role so proposals classified
    # under that taxonomy can be automatically assigned to the evaluator.
    class TaxonomyEvaluator < ApplicationRecord
      include Decidim::Traceable
      include Decidim::Loggable

      self.table_name = "decidim_reporting_proposals_taxonomy_evaluators"

      belongs_to :taxonomy, foreign_key: "decidim_taxonomy_id", class_name: "Decidim::Taxonomy"
      belongs_to :evaluator_role, polymorphic: true

      delegate :user, to: :evaluator_role

      validates :taxonomy, uniqueness: { scope: [:evaluator_role] }
      validate :taxonomy_belongs_to_same_organization

      def self.log_presenter_class_for(_log)
        Decidim::ReportingProposals::AdminLog::TaxonomyEvaluatorPresenter
      end

      # Nearest-ancestor-wins resolution: each taxonomy resolves to the first
      # level of its self -> parent -> ... -> root chain (part_of keeps that
      # order) having any assignment among the given evaluator roles; ancestor
      # assignments are never merged. Returns { taxonomy => [TaxonomyEvaluator] }.
      def self.assignments_for(taxonomies, evaluator_roles)
        assignments = where(evaluator_role: evaluator_roles, decidim_taxonomy_id: taxonomies.flat_map(&:part_of).uniq)
                      .includes(evaluator_role: :user)
                      .group_by(&:decidim_taxonomy_id)
        taxonomies.index_with do |taxonomy|
          nearest_id = taxonomy.part_of.find { |id| assignments.has_key?(id) }
          assignments.fetch(nearest_id, [])
        end
      end

      private

      def taxonomy_belongs_to_same_organization
        return if !taxonomy || !evaluator_role
        return if taxonomy.organization == evaluator_role.participatory_space.organization

        errors.add(:taxonomy, :invalid)
      end
    end
  end
end
