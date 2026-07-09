# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module FormBuilderOverride
      include Decidim::LayoutHelper

      # These methods are used in deeper levels and might not be available in this context when this is called, thus the delegation
      delegate :asset_pack_path, to: :@template

      def file_field(object_name, options = {})
        options = options.dup
        # Server-driven `accept` so the OS file picker only offers allowed types.
        # Callers can still pass an explicit `accept` to override this.
        options[:accept] ||= reporting_proposals_picker_accept(object_name)

        return super unless reporting_proposals_camera_field?(object_name)
        return super unless @template.respond_to?(:snippets)

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

      # The camera button is a reporting-proposals feature: the attachments
      # upload of the public reporting-proposal form and the admin photo form
      def reporting_proposals_camera_field?(object_name)
        return false unless Decidim::ReportingProposals.use_camera_button
        return true if reporting_proposals_photo_form?

        object_name.to_s.include?("attachment") &&
          @template.try(:reporting_proposal?) == true &&
          @template.controller.class.name.exclude?("::Admin::")
      end

      # `accept` from the server-side allowlist; nil (no-op) when not resolvable
      def reporting_proposals_picker_accept(object_name)
        extensions =
          if reporting_proposals_photo_form?
            Decidim.organization_settings(@template.current_organization).upload_allowed_file_extensions_image
          else
            Decidim::FileValidatorHumanizer.new(object, object_name.to_s.sub(/\Aadd_/, "").to_sym).extension_allowlist
          end

        extensions.presence&.map { |ext| ".#{ext}" }&.join(",")
      rescue StandardError
        nil
      end

      def reporting_proposals_photo_form?
        @object_name.to_s.include?("proposal_photo")
      end
    end
  end
end
