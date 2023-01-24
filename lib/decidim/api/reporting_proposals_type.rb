# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class ReportingProposalsType < Decidim::Proposals::ProposalsType
      graphql_name "ReportingProposals"
      description "A reporting proposals component of a participatory space."
    end
  end
end
