# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "decidim/reporting_proposals/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-reporting_proposals"
  spec.version = Decidim::ReportingProposals::VERSION
  spec.authors = ["Ivan Vergés"]
  spec.email = ["ivan@pokecode.net"]

  spec.summary = "A module for Decidim that facilitates the creation of proposals related to geolocated issues in a city."
  spec.description = "A module for Decidim that facilitates the creation of proposals related to geolocated issues in a city"
  spec.license = "AGPL-3.0"
  spec.homepage = "https://github.com/openpoke/decidim-module-reporting_proposals"
  spec.required_ruby_version = ">= 2.7"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "decidim-admin", Decidim::ReportingProposals::COMPAT_DECIDIM_VERSION
  spec.add_dependency "decidim-core", Decidim::ReportingProposals::COMPAT_DECIDIM_VERSION
  spec.add_dependency "decidim-participatory_processes", Decidim::ReportingProposals::COMPAT_DECIDIM_VERSION
  spec.add_dependency "decidim-proposals", Decidim::ReportingProposals::COMPAT_DECIDIM_VERSION
  spec.add_dependency "deface", ">= 1.9"

  spec.add_development_dependency "decidim-dev", Decidim::ReportingProposals::COMPAT_DECIDIM_VERSION
  spec.add_development_dependency "decidim-templates", Decidim::ReportingProposals::COMPAT_DECIDIM_VERSION
end
