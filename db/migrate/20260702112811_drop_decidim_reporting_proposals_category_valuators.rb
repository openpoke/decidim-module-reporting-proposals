# frozen_string_literal: true

# Category-valuator rows are NOT converted to taxonomy evaluators: the
# category->taxonomy mapping is only created by `decidim:taxonomies:import_plan`,
# which runs after migrations, so no matching taxonomies exist at this point.
# Admins must reconfigure evaluators per taxonomy after importing taxonomies.
class DropDecidimReportingProposalsCategoryValuators < ActiveRecord::Migration[7.2]
  def change
    drop_table :decidim_reporting_proposals_category_valuators do |t|
      t.references :decidim_category, null: false, foreign_key: { to_table: "decidim_categories" }, index: { name: "decidim_reporting_proposals_category_category_id" }
      t.references :valuator_role, polymorphic: true, null: false, index: { name: "decidim_reporting_proposals_category_valuator_role" }

      t.timestamps
    end
  end
end
