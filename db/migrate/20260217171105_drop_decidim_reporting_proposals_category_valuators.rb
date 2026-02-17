class DropDecidimReportingProposalsCategoryValuators < ActiveRecord::Migration[6.0]
  def change
    drop_table :decidim_reporting_proposals_category_valuators do |t|
      t.references :decidim_category, null: false, foreign_key: { to_table: "decidim_categories" }, index: { name: "decidim_reporting_proposals_category_category_id" }
      t.references :valuator_role, polymorphic: true, null: false, index: { name: "decidim_reporting_proposals_category_valuator_role" }

      t.timestamps
    end
  end
end
