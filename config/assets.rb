# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_reporting_proposals: "#{base_path}/app/packs/entrypoints/decidim_reporting_proposals.js",
  decidim_reporting_proposals_manage_component_admin: "#{base_path}/app/packs/entrypoints/decidim_reporting_proposals_manage_component_admin.js",
  decidim_reporting_proposals_list_component_admin: "#{base_path}/app/packs/entrypoints/decidim_reporting_proposals_list_component_admin.js",
  decidim_reporting_proposals_geocoding: "#{base_path}/app/packs/entrypoints/decidim_reporting_proposals_geocoding.js",
  decidim_reporting_proposals_camera: "#{base_path}/app/packs/entrypoints/decidim_reporting_proposals_camera.js",
  decidim_reporting_proposals_js_validations: "#{base_path}/app/packs/entrypoints/decidim_reporting_proposals_js_validations.js",
  decidim_templates_admin: "#{base_path}/app/packs/entrypoints/decidim_templates_admin.js"
)
