# frozen_string_literal: true

require "decidim/reporting_proposals/config"
require "decidim/reporting_proposals/admin"
require "decidim/reporting_proposals/admin_engine"
require "decidim/reporting_proposals/engine"
require "decidim/reporting_proposals/component"

module Decidim
  module ReportingProposals
    autoload :ReportingProposalsType, "decidim/api/reporting_proposals_type"
  end
end
