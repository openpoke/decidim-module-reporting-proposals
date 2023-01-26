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
        @radius = proposal.component.settings.geocoding_comparison_radius
        @newer_than = proposal.component.settings.geocoding_comparison_newer_than
      end

      # Retrieves similar proposals
      def query
        base_query
          .near([@proposal.latitude, @proposal.longitude], @radius.to_f / 1000, units: :km)
          .limit(Decidim::Proposals.similarity_limit)
      end

      def base_query
        @base_query = Decidim::Proposals::Proposal
                      .where(component: @components)
                      .published
                      .not_hidden

        return @base_query if @newer_than.zero?

        @base_query.where("published_at > ?", @newer_than.days.ago)
      end
    end
  end
end
