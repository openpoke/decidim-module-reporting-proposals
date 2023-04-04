# frozen_string_literal: true

class MigrateTemplatable < ActiveRecord::Migration[6.0]
  def self.up
    Decidim::Templates::Template.find_each do |template|
      next if template.target.present?

      template.update(target: template.templatable_type.demodulize.tableize.singularize)
    end
  end

  def self.down; end
end
