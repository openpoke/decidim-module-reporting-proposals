# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalAnswerTemplatesControllerOverride
        extend ActiveSupport::Concern

        included do
          def availability_options # rubocop:disable Decidim/EnforcePermissionTo
            @availability_options = []

            Decidim::Component.includes(:participatory_space).where(manifest_name: accepted_components) # rubocop:disable Decidim/OrganizationScopedFinder -- result is filtered in-memory below by current_organization
                              .select { |a| a.participatory_space.decidim_organization_id == current_organization.id }.each do |component|
              @availability_options.push [formatted_name(component), component.id]
            end

            @availability_options.sort_by!(&:first)
          end

          private

          def accepted_components
            [:proposals, :reporting_proposals]
          end
        end
      end
    end
  end
end
