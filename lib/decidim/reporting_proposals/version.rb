# frozen_string_literal: true

module Decidim
  module ReportingProposals
    VERSION = "0.3.0"
    # DECIDIM_VERSION = "0.26.5"
    # Provisional until
    #   https://github.com/openpoke/decidim/pull/23
    #   https://github.com/openpoke/decidim/pull/37
    # are merged on upstream
    DECIDIM_VERSION = { github: "openpoke/decidim", branch: "0.26-lucerne" }.freeze

    COMPAT_DECIDIM_VERSION = [">= 0.25.0", "< 0.27"].freeze
  end
end
