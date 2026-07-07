# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # This controller allows admins to manage the automatic taxonomy
      # evaluators in a participatory process.
      class ParticipatoryProcessTaxonomyEvaluatorsController < TaxonomyEvaluatorsController
        include Decidim::ParticipatoryProcesses::Admin::Concerns::ParticipatoryProcessAdmin
      end
    end
  end
end
