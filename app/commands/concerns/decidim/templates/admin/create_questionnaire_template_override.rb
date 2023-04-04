# frozen_string_literal: true

module Decidim
  module Templates
    # A command with all the business logic when duplicating a questionnaire template
    module Admin
      module CreateQuestionnaireTemplateOverride
        extend ActiveSupport::Concern

        included do
          def call
            return broadcast(:invalid) unless @form.valid?

            @template = Decidim.traceability.create!(
              Template,
              @form.current_user,
              name: @form.name,
              description: @form.description,
              organization: @form.current_organization,
              target: :questionnaire
            )

            @questionnaire = Decidim::Forms::Questionnaire.create!(questionnaire_for: @template)
            @template.update!(templatable: @questionnaire)

            broadcast(:ok, @template)
          end
        end
      end
    end
  end
end
