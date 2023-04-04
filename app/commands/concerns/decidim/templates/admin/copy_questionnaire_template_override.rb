# frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a questionnaire template
    module Admin
      module CopyQuestionnaireTemplateOverride
        extend ActiveSupport::Concern

        included do
          private

          def copy_template
            @copied_template = Template.create!(
              organization: @template.organization,
              name: @template.name,
              description: @template.description,
              target: :questionnaire
            )
            @resource = Decidim::Forms::Questionnaire.create!(
              @template.templatable.dup.attributes.merge(
                questionnaire_for: @copied_template
              )
            )

            @copied_template.update!(templatable: @resource)
          end
        end
      end
    end
  end
end
