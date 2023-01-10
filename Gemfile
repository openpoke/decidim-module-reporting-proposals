# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/reporting_proposals/version"

# DECIDIM_VERSION = Decidim::ReportingProposals::DECIDIM_VERSION
# Provisional until https://github.com/openpoke/decidim/pull/23 is merge in upstream
DECIDIM_VERSION = { github: "openpoke/decidim", branch: "feat/evaluator-emails" }.freeze

gem "decidim", DECIDIM_VERSION
gem "decidim-reporting_proposals", path: "."

gem "bootsnap", "~> 1.7"
gem "faker", "~> 2.14"
gem "rspec", "~> 3.0"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "rubocop-faker"
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console"
end

group :test do
  gem "codecov", require: false
end
