# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module FormBuilderOverride
      extend ActiveSupport::Concern
      include Decidim::LayoutHelper

      # These methods are used in deeper levels and might not be available in this context when this is called, thus the delegation
      delegate :asset_pack_path, to: :@template

      included do
        alias_method :original_file_field, :file_field

        def file_field(object_name, options = {})
          options = options.dup
          # Server-driven `accept` so the OS file picker only offers allowed types.
          # Callers can still pass an explicit `accept` to override this.
          options[:accept] ||= reporting_proposals_picker_accept(object_name)

          return original_file_field(object_name, options) unless Decidim::ReportingProposals.use_camera_button
          return original_file_field(object_name, options) unless @template.respond_to?(:snippets)

          unless @template.snippets.any?(:reporting_proposals_camera_scripts) || @template.snippets.any?(:reporting_proposals_camera_styles)
            @template.snippets.add(:reporting_proposals_camera_scripts, @template.prepend_javascript_pack_tag("decidim_reporting_proposals_camera"))
            @template.snippets.add(:reporting_proposals_camera_styles, @template.append_stylesheet_pack_tag("decidim_reporting_proposals_camera"))

            # This will display the snippets in the <head> part of the page.
            @template.snippets.add(:head, @template.snippets.for(:reporting_proposals_camera_styles))
            @template.snippets.add(:foot, @template.snippets.for(:reporting_proposals_camera_scripts))
          end

          content_tag(:div, class: "camera-container input-group") do
            super(object_name, options) +
              content_tag(:div, class: "input-group-button") do
                content_tag(:button,
                            class: "button button__secondary user-device-camera",
                            type: "button",
                            data: { input: object_name }) do
                  icon("camera-line", role: "img", "aria-hidden": true) + " #{I18n.t("use_my_camera", scope: "decidim.reporting_proposals.forms")}"
                end
              end
          end
        end

        private

        # Builds the `accept` value for a file input from the server-side allowlist.
        # Photo fields use the image-only extension set; every other field uses the
        # per-context (admin vs participant) allowlist resolved by FileValidatorHumanizer.
        # Returns nil for any field without a resolvable allowlist so it stays a no-op.
        def reporting_proposals_picker_accept(object_name)
          extensions =
            if object_name.to_s.include?("photo")
              Decidim.organization_settings(@template.current_organization).upload_allowed_file_extensions_image
            else
              Decidim::FileValidatorHumanizer.new(object, object_name.to_s.sub(/\Aadd_/, "").to_sym).extension_allowlist
            end

          extensions.presence&.map { |ext| ".#{ext}" }&.join(",")
        rescue StandardError
          nil
        end
      end
    end
  end
end
