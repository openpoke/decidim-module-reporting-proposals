# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module FormBuilderOverride
      extend ActiveSupport::Concern
      include Decidim::LayoutHelper

      # These methods are used in deeper levels and might not be available in this context when this is called, thus the delegation
      delegate :asset_pack_path, to: :@template

      included do
        alias_method :original_attachment, :attachment

        def attachment(attribute, options = {})
          original = original_attachment(attribute, options)

          return original unless use_camera_button?(attribute)

          unless @template.snippets.any?(:reporting_proposals_camera_scripts) || @template.snippets.any?(:reporting_proposals_camera_styles)
            @template.snippets.add(:reporting_proposals_camera_scripts, @template.javascript_pack_tag("decidim_reporting_proposals_camera"))
            @template.snippets.add(:reporting_proposals_camera_styles, @template.stylesheet_pack_tag("decidim_reporting_proposals_camera"))

            # This will display the snippets in the <head> part of the page.
            @template.snippets.add(:head, @template.snippets.for(:reporting_proposals_camera_styles))
            @template.snippets.add(:foot, @template.snippets.for(:reporting_proposals_camera_scripts))
          end

          content_tag(:div, class: "camera-container") do
            original +
              content_tag(:button, class: "button secondary user-device-camera", type: "button", data: { input: attribute }) do
                icon("camera-slr", role: "img", "aria-hidden": true) + " #{I18n.t("use_my_camera", scope: "decidim.reporting_proposals.forms")}"
              end
          end
        end

        private

        def use_camera_button?(attribute)
          return unless @template.respond_to?(:current_component)

          return unless Decidim::ReportingProposals.use_camera_button.include?(@template.current_component.manifest_name.to_sym)

          return attribute == :photos unless Decidim::ReportingProposals.camera_button_on_attachments

          true
        end
      end
    end
  end
end
