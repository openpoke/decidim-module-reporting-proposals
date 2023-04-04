# frozen_string_literal: true

class AddTargetAndFieldValuesToDecidimTemplatesTemplates < ActiveRecord::Migration[6.0]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:decidim_templates_templates, :field_values)
      add_column :decidim_templates_templates, :field_values, :json, default: {}
    end
    unless ActiveRecord::Base.connection.column_exists?(:decidim_templates_templates, :target)
      add_column :decidim_templates_templates, :target, :string
    end
  end
end
