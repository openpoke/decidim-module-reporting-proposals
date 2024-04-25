# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ResourceManifestOverride
      extend ActiveSupport::Concern

      included do
        # The name of the named Rails route to create the url to admin the resource
        # If it is not defined, the resource will be considered non-administrable
        # and no link will be generated in some places
        attribute :admin_route_name, String
      end
    end
  end
end
