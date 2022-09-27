# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module MapBuilderOverride
      extend ActiveSupport::Concern
      include Decidim::LayoutHelper

      # These methods might not be available in this context when this is called, thus the delegation
      delegate :content_tag, to: "template"
      delegate :asset_pack_path, to: "ActionController::Base.helpers"

      included do
        def geocoding_field(object_name, method, options = {})
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
              template.content_tag(:div, class: "input-group-button") do
                template.content_tag(:button, class: "button secondary") do
                  icon("location", role: "img", "aria-hidden": true) + " #{I18n.t("use_my_location", scope: "decidim.reporting_proposals.forms")}"
                end
              end
          end
        end
      end
    end
  end
end
