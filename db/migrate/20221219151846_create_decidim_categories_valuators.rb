# frozen_string_literal: true

class CreateDecidimCategoriesValuators < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_categories_valuators do |t|
      t.references :decidim_category, null: false, index: true, foreign_key: { to_table: "decidim_categories" }
      t.references :decidim_user, null: false, index: true, foreign_key: { to_table: "decidim_users" }
      t.timestamps
    end

    add_index :decidim_categories_valuators,
              [:decidim_category_id, :decidim_user_id],
              unique: true,
              name: "decidim_categories_valuators_category_user_unique"
  end
end
