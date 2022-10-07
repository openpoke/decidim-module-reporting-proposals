# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module MapBuilderOverride
      extend ActiveSupport::Concern
      include Decidim::LayoutHelper

      # These methods are used in deeper levels and might not be available in this context when this is called, thus the delegation
      delegate :content_tag, :asset_pack_path, to: :template

      included do
        alias_method :original_geocoding_field, :geocoding_field

        def geocoding_field(object_name, method, options = {})
          return original_geocoding_field(object_name, method, options) unless show_my_location_button?

          unless template.snippets.any?(:reporting_proposals_geocoding_addons)
            template.snippets.add(:reporting_proposals_geocoding_addons, template.javascript_pack_tag("decidim_reporting_proposals_geocoding"))
            template.snippets.add(:reporting_proposals_geocoding_addons, template.stylesheet_pack_tag("decidim_reporting_proposals_geocoding"))

            # This will display the snippets in the <head> part of the page.
            template.snippets.add(:head, template.snippets.for(:reporting_proposals_geocoding_addons))
          end

          options[:autocomplete] ||= "off"
          options[:class] ||= "input-group-field"

          template.content_tag(:div, class: "input-group") do
            template.text_field(
              object_name,
              method,
              options.merge("data-decidim-geocoding" => view_options.to_json)
            ) +
              template.content_tag(:div, class: "input-group-button user-device-location") do
                template.content_tag(:button, class: "button secondary", type: "button", data: {
                                       input: "#{object_name}_#{method}",
                                       latitude: "#{object_name}_latitude",
                                       longitude: "#{object_name}_longitude",
                                       error_no_location: I18n.t("errors.no_device_location", scope: "decidim.reporting_proposals.forms"),
                                       error_unsupported: I18n.t("errors.device_not_supported", scope: "decidim.reporting_proposals.forms"),
                                       url: Decidim::ReportingProposals::Engine.routes.url_helpers.locate_path
                                     }) do
                  icon("location", role: "img", "aria-hidden": true) + " #{I18n.t("use_my_location", scope: "decidim.reporting_proposals.forms")}"
                end
              end
          end
        end

        private

        def show_my_location_button?
          return unless template.respond_to?(:current_component)

          Decidim::ReportingProposals.show_my_location_button.include?(template.current_component.manifest_name.to_sym)
        end
      end
    end
  end
end
