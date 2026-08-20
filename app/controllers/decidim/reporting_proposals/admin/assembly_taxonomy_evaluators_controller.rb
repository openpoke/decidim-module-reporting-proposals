# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # This controller allows admins to manage the automatic taxonomy
      # evaluators in an assembly.
      class AssemblyTaxonomyEvaluatorsController < TaxonomyEvaluatorsController
        include Decidim::Assemblies::Admin::Concerns::AssemblyAdmin if defined?(Decidim::Assemblies::AdminEngine)
      end
    end
  end
end
