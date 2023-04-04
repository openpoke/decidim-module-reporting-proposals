# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ResourceLocatorPresenterOverride
      extend ActiveSupport::Concern

      included do
        # Generates and admin url only if the manifest has the property :admin_route_name defined
        # this allows to distinct from resources that can be administrated from those that are not
        def admin_url(options = {})
          admin_member_route("url", options.merge(host: root_resource.organization.host))
        end

        private

        def admin_member_route(route_type, options)
          return if manifest_for(target).admin_route_name.blank?

          options.merge!(options_for_polymorphic)
          admin_route_proxy.send("#{admin_member_route_name}_#{route_type}", target, options)
        end

        def admin_member_route_name
          if polymorphic?
            admin_polymorphic_member_route_name
          else
            manifest_for(target).admin_route_name
          end
        end

        def admin_polymorphic_member_route_name
          return unless polymorphic?

          resource.map { |record| manifest_for(record).admin_route_name }.join("_")
        end
      end
    end
  end
end
