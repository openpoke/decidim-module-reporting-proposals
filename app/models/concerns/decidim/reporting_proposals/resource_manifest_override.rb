# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ResourceManifestOverride
      extend ActiveSupport::Concern

      included do
        attribute :admin_route_name, String
      end
    end
  end
end
