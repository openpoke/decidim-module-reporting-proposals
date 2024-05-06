# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ReportedMailerOverride
      extend ActiveSupport::Concern

      included do
        helper Decidim::ComponentPathHelper
        helper_method :resource_admin_url

        def resource_admin_url
          @resource_admin_url ||= Decidim::ResourceLocatorPresenter.new(@reportable).admin_url
        end
      end
    end
  end
end
