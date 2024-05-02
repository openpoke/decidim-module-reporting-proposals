# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module UpdateProposalAnswerTemplateOverride
        extend ActiveSupport::Concern

        included do
          private

          def identify_templateable_resource
            resource = @form.current_organization
            if @form.component_constraint.present?
              found_component = Decidim::Component.find_by(id: @form.component_constraint, manifest_name: %w(proposals reporting_proposals))
              if found_component.present?
                resource = found_component&.participatory_space&.decidim_organization_id == @form.current_organization.id ? found_component : nil
              end
            end
            resource
          end
        end
      end
    end
  end
end
