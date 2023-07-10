# frozen_string_literal: true

class AddTargetAndFieldValuesToDecidimTemplatesTemplates < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_templates_templates, :field_values, :json, default: {} unless ActiveRecord::Base.connection.column_exists?(:decidim_templates_templates, :field_values)
    add_column :decidim_templates_templates, :target, :string unless ActiveRecord::Base.connection.column_exists?(:decidim_templates_templates, :target)
  end
end
