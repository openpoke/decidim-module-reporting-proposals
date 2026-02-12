# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/reporting_proposals/version"

DECIDIM_VERSION = Decidim::ReportingProposals::DECIDIM_VERSION

gem "decidim", DECIDIM_VERSION
gem "decidim-reporting_proposals", path: "."

gem "bootsnap", "~> 1.7"
gem "puma", ">= 6.3.1"
# seems that rexml 3.4.1 have issues generating some XMLs and codecov compatibility
gem "rexml", "3.4.1"

group :development, :test do
  gem "brakeman", "~> 6.1"
  gem "byebug", "~> 11.0", platform: :mri
  gem "decidim-dev", DECIDIM_VERSION
  gem "decidim-initiatives", DECIDIM_VERSION
  gem "decidim-templates", DECIDIM_VERSION
  gem "faker", "~> 3.3.1"
  gem "parallel_tests", "~> 4.2"
end

group :development do
  gem "letter_opener_web"
  gem "listen", "~> 3.1"
  gem "web-console"
end

group :test do
  gem "codecov", require: false
end
