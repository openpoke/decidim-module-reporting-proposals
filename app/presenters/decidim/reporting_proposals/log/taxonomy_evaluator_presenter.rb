# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Log
      class TaxonomyEvaluatorPresenter < Decidim::Log::ResourcePresenter
        private

        # Private: Presents resource name.
        #
        # Returns an HTML-safe String.
        def present_resource_name
          if resource.present?
            decidim_escape_translated(resource.taxonomy.name).html_safe
          else
            super
          end
        end
      end
    end
  end
end
