# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module NeedsHeaderSnippets
        extend ActiveSupport::Concern

        included do
          helper_method :snippets
        end

        def snippets
          @snippets ||= Decidim::Snippets.new

          unless @snippets.any?(:reporting_proposals_snippets) && reporting_proposals_component?
            @snippets.add(:reporting_proposals_snippets, ActionController::Base.helpers.stylesheet_pack_tag("decidim_reporting_proposals_component_admin"))
            @snippets.add(:head, @snippets.for(:reporting_proposals_snippets))
          end

          @snippets
        end

        def reporting_proposals_component?
          current_component&.manifest_name == "reporting_proposals"
        end

        def current_component
          return unless query_scope && query_scope.respond_to?(:find)

          @current_component ||= query_scope.find(params[:id])
        end
      end
    end
  end
end
