# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module ProposalAnswerTemplateOverride
        extend ActiveSupport::Concern

        included do
          private

          def identify_templateable_resource
            found_component = Decidim::Component.find_by(id: @form.component_constraint, manifest_name: %(proposals reporting_proposals))
            if found_component.present?
              resource = found_component&.participatory_space&.decidim_organization_id == @form.current_organization.id ? found_component : nil
            end
            resource
          end
        end
      end
    end
  end
end
