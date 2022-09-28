# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class GeolocationController < Decidim::ReportingProposals::ApplicationController
      def address
        # TODO: return :unprocessable_entity if not configured or failure
        geocoder = Decidim::Map.utility(:geocoding, organization: current_organization)
        address = geocoder.address([params[:latitude], params[:longitude]])
        render json: { address: address, found: address.present? }
      end
    end
  end
end
