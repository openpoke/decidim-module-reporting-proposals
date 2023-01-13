# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module NeedsProposalExtraValidationsSnippets
      extend ActiveSupport::Concern

      included do
        helper_method :snippets
      end

      def snippets
        @snippets ||= Decidim::Snippets.new

        unless @snippets.any?(:reporting_proposals_js_validations)
          @snippets.add(:reporting_proposals_js_validations, ActionController::Base.helpers.javascript_pack_tag("decidim_reporting_proposals_js_validations"))
          @snippets.add(:reporting_proposals_js_validations, rules_tag)
          @snippets.add(:head, @snippets.for(:reporting_proposals_js_validations))
        end
        @snippets
      end

      def rules_tag
        content_tag(:script, "Decidim.ProposalRules = #{rules.to_json};".html_safe)
      end

      # caps rules are not explicitly used in the JS validations
      def rules
        model = Decidim::Proposals::Proposal.new(title: "title", body: "body")
        etiquette_validator = EtiquetteValidator.new(attributes: [:title, :body])
        etiquette_validator.validate(model)
        {
          genericError: I18n.t("decidim.forms.errors.error"),
          title: {
            caps: {
              enabled: model.errors.details[:title].to_s.include?(":must_start_with_caps"),
              error: I18n.t("errors.messages.must_start_with_caps")
            }
          },
          body: {
            caps: {
              enabled: model.errors.details[:body].to_s.include?(":must_start_with_caps"),
              error: I18n.t("errors.messages.must_start_with_caps")
            }
          }
        }
      end
    end
  end
end
