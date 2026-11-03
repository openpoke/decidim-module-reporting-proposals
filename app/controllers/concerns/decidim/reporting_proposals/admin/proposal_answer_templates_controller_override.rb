# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalAnswerTemplatesControllerOverride
        extend ActiveSupport::Concern

        included do
          def availability_options # rubocop:disable Decidim/EnforcePermissionTo
            @availability_options ||= available_components.map do |component|
              [formatted_name(component), component.id]
            end.sort_by(&:first)
          end

          private

          def proposal
            @proposal ||= Decidim::Proposals::Proposal.where(decidim_component_id: available_components.map(&:id)) # rubocop:disable Decidim/OrganizationScopedFinder -- scoped via components in current_organization participatory spaces
                                                      .find_by(id: params[:proposalId].to_i)
          end

          def accepted_components
            [:proposals, :reporting_proposals]
          end

          def available_components
            Decidim::Component.includes(:participatory_space).where(manifest_name: accepted_components) # rubocop:disable Decidim/OrganizationScopedFinder -- result is filtered in-memory below by current_organization
                              .select { |a| a.participatory_space.decidim_organization_id == current_organization.id }
          end
        end
      end
    end
  end
end
