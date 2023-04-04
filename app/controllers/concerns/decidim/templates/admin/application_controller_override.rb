# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      module ApplicationControllerOverride
        extend ActiveSupport::Concern

        included do
          def template_types
            @template_types ||= {
              I18n.t("template_types.questionnaires", scope: "decidim.templates") => decidim_admin_templates.questionnaire_templates_path,
              I18n.t("template_types.proposal_answer_templates", scope: "decidim.templates") => decidim_admin_templates.proposal_answer_templates_path
            }
          end
        end
      end
    end
  end
end
