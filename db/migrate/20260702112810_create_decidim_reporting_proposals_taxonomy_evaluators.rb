# frozen_string_literal: true

class CreateDecidimReportingProposalsTaxonomyEvaluators < ActiveRecord::Migration[7.2]
  def change
    create_table :decidim_reporting_proposals_taxonomy_evaluators do |t|
      # the composite unique index below already covers lookups by decidim_taxonomy_id
      # cascade: Decidim::Taxonomy has no association to this table, so deleting
      # a taxonomy would otherwise raise ActiveRecord::InvalidForeignKey
      t.references :decidim_taxonomy, null: false, foreign_key: { to_table: :decidim_taxonomies, on_delete: :cascade }, index: false
      t.references :evaluator_role, polymorphic: true, null: false, index: { name: "decidim_reporting_proposals_taxonomy_evaluator_role" }

      t.timestamps
    end

    add_index :decidim_reporting_proposals_taxonomy_evaluators,
              [:decidim_taxonomy_id, :evaluator_role_id, :evaluator_role_type],
              unique: true,
              name: "decidim_reporting_proposals_taxonomy_evaluator_unique"
  end
end
