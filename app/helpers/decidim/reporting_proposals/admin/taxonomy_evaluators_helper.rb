# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module TaxonomyEvaluatorsHelper
        # static class list so Tailwind purge keeps them;
        # Decidim::Taxonomy allows 3 nesting levels at most
        def taxonomy_indent_class(taxonomy)
          ["", "pl-6", "pl-12", "pl-16"][taxonomy.parent_ids.count]
        end
      end
    end
  end
end
