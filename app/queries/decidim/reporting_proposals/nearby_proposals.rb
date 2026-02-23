# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Class used to retrieve similar proposals.
    class NearbyProposals < Decidim::Query
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

      # Retrieves similar proposals by distance
      def query
        return Decidim::Proposals::Proposal.none if query_ids.blank?

        Decidim::Proposals::Proposal
          .where(id: query_ids)
          .order([Arel.sql("array_position(ARRAY[?], id)"), query_ids])
      end

      private

      # we won't return directly this query due a problem with the method "count" in the geocoder gem
      # see https://github.com/alexreisner/geocoder#note-on-rails-41-and-greater
      def query_ids
        base_query.near([@proposal.latitude, @proposal.longitude], @radius.to_f / 1000, units: :km).map(&:id)
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
