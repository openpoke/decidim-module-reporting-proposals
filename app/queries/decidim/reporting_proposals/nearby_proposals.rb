# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Class used to retrieve similar proposals.
    class NearbyProposals < Rectify::Query
      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # components - Decidim::CurrentComponent
      # proposal - Decidim::Proposals::Proposal
      def self.for(components, proposal)
        new(components, proposal).query
      end

      # Initializes the class.
      #
      # components - Decidim::CurrentComponent
      # proposal - Decidim::Proposals::Proposal
      def initialize(components, proposal)
        @components = components
        @proposal = proposal
        @radius = proposal.component.settings.geocoding_comparison_radius.to_f
        # @after_date = proposal.component.geocoding_comparison_after_date
      end

      # Retrieves similar proposals
      def query
        Decidim::Proposals::Proposal
          .where(component: @components)
          .published
          .not_hidden
          .near([@proposal.latitude, @proposal.longitude], @radius / 1000, units: :km)
          .limit(Decidim::Proposals.similarity_limit)
      end
    end
  end
end
