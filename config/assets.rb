# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_reporting_proposals: "#{base_path}/app/packs/entrypoints/decidim_reporting_proposals.js",
  decidim_reporting_proposals_component_admin: "#{base_path}/app/packs/entrypoints/decidim_reporting_proposals_component_admin.js"
)
