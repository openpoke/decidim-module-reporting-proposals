# frozen_string_literal: true

require "decidim/reporting_proposals/engine"
require "decidim/reporting_proposals/component"

module Decidim
  # This namespace holds the logic of the `decidim-reporting_proposals` module.
  module ReportingProposals
    include ActiveSupport::Configurable
  end
end
