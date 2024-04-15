# frozen_string_literal: true

FactoryBot.define do
  factory :reporting_proposals_component, parent: :proposal_component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :reporting_proposals).i18n_name }
    manifest_name { :reporting_proposals }
  end

  factory :category_valuator, class: "Decidim::ReportingProposals::CategoryValuator" do
    category { association :category, participatory_space: valuator_role.participatory_space }
    valuator_role { association :participatory_process_user_role, role: "valuator" }
  end
end

FactoryBot.modify do
  factory :template, class: "Decidim::Templates::Template" do
    trait :proposal_answer do
      templatable { organization }
      target { :proposal_answer }
      field_values { { internal_state: :accepted } }
    end
  end
end
