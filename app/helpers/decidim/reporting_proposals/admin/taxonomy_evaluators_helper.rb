# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module TaxonomyEvaluatorsHelper
        # static list so Tailwind purge keeps the classes; taxonomies nest 3 levels max
        def taxonomy_indent_class(taxonomy)
          ["", "pl-6", "pl-12", "pl-16"][taxonomy.parent_ids.count]
        end
      end
    end
  end
end
