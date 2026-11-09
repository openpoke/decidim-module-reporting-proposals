# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module ProposalAnswerTemplateOverride
        private

        def identify_templateable_resource
          return super if @form.component_constraint.blank?

          Decidim::Component.for_organization(organization: current_organization)
                            .find_by(id: @form.component_constraint, manifest_name: %w(proposals reporting_proposals)) || super
        end
      end
    end
  end
end
