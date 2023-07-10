# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module FormBuilderOverride
      extend ActiveSupport::Concern
      include Decidim::LayoutHelper

      # These methods are used in deeper levels and might not be available in this context when this is called, thus the delegation
      delegate :asset_pack_path, to: :@template

      included do
        def file_field(object_name, method, options = {})
          return super(object_name, method, options) unless use_camera_button?(object_name)

          unless @template.snippets.any?(:reporting_proposals_camera_addons)
            @template.snippets.add(:reporting_proposals_camera_addons, @template.javascript_pack_tag("decidim_reporting_proposals_camera"))
            @template.snippets.add(:reporting_proposals_camera_addons, @template.stylesheet_pack_tag("decidim_reporting_proposals_camera"))

            # This will display the snippets in the <head> part of the page.
            @template.snippets.add(:head, @template.snippets.for(:reporting_proposals_camera_addons))
          end

          content_tag(:div, class: "input-group") do
            super(object_name, method, options) +
              content_tag(:div, class: "input-group-button") do
                content_tag(:button, class: "button secondary user-device-camera", type: "button", data: { input: "#{object_name}_#{method}" }) do
                  icon("camera-slr", role: "img", "aria-hidden": true) + " #{I18n.t("use_my_camera", scope: "decidim.reporting_proposals.forms")}"
                end
              end
          end
        end

        private

        def use_camera_button?(object_name)
          return unless @template.respond_to?(:current_component)

          return unless Decidim::ReportingProposals.use_camera_button.include?(@template.current_component.manifest_name.to_sym)

          object_name == :add_photos
        end
      end
    end
  end
end
