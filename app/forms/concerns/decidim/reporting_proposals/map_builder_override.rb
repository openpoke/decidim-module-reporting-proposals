# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module MapBuilderOverride
      # Upstream shows the "Use my location" button only in the proposals
      # component; make the component list configurable
      def show_my_location_button?
        return false unless template.respond_to?(:current_component)

        Decidim::ReportingProposals.show_my_location_button.include?(template.current_component.manifest_name.to_sym)
      end
    end
  end
end
