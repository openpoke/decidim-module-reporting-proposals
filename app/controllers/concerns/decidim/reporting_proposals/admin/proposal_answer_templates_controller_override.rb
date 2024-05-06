# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalAnswerTemplatesControllerOverride
        extend ActiveSupport::Concern

        included do
          def avaliablity_options
            @avaliablity_options = []

            Decidim::Component.includes(:participatory_space).where(manifest_name: accepted_components)
                              .select { |a| a.participatory_space.decidim_organization_id == current_organization.id }.each do |component|
              @avaliablity_options.push [formatted_name(component), component.id]
            end

            @avaliablity_options.sort_by!(&:first)
            @avaliablity_options.prepend [t("global_scope", scope: "decidim.templates.admin.proposal_answer_templates.index"), 0]
          end

          # This is overriden because a bug in decidim templates that prevents valuators to use templates
          # This can be removed after https://github.com/decidim/decidim/pull/12765 is merge & backported
          def fetch
            enforce_permission_to(:read, :template, template:, proposal:)

            response_object = {
              state: template.field_values["internal_state"],
              template: populate_template_interpolations(proposal)
            }

            respond_to do |format|
              format.json do
                render json: response_object.to_json
              end
            end
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
