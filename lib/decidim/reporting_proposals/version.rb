# frozen_string_literal: true

module Decidim
  module ReportingProposals
    VERSION = "0.9.0"
    DECIDIM_VERSION = { github: "decidim/decidim", branch: "release/0.32-stable" }.freeze
    COMPAT_DECIDIM_VERSION = [">= 0.32", "< 0.33"].freeze
  end
end
