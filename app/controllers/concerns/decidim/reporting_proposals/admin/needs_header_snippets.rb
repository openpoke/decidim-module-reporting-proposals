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

          unless @snippets.any?(:reporting_proposals_manage_component) && reporting_proposals_component?
            @snippets.add(:reporting_proposals_manage_component, ActionController::Base.helpers.stylesheet_pack_tag("decidim_reporting_proposals_manage_component_admin"))
            @snippets.add(:head, @snippets.for(:reporting_proposals_manage_component))
          end

          unless @snippets.any?(:reporting_proposals_list_component) && any_proposals_component?
            @snippets.add(:reporting_proposals_list_component, ActionController::Base.helpers.stylesheet_pack_tag("decidim_reporting_proposals_list_component_admin"))
            @snippets.add(:head, @snippets.for(:reporting_proposals_list_component))
          end

          @snippets
        end

        def reporting_proposals_component?
          current_component&.manifest_name == "reporting_proposals"
        end

        def any_proposals_component?
          current_component&.manifest_name.in? %w(proposals reporting_proposals)
        end

        def current_component
          @current_component ||= begin
            if defined?(query_scope) && query_scope.respond_to?(:find)
              query_scope.find_by(id: params[:id])
            elsif params.has_key?(:component_id)
              Decidim::Component.find_by(id: params[:component_id])
            end
          end
        end
      end
    end
  end
end
