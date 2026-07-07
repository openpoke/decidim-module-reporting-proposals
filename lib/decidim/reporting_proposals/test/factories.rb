# frozen_string_literal: true

FactoryBot.define do
  factory :reporting_proposals_component, parent: :proposal_component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :reporting_proposals).i18n_name }
    manifest_name { :reporting_proposals }
  end

  factory :taxonomy_evaluator, class: "Decidim::ReportingProposals::TaxonomyEvaluator" do
    taxonomy { association :taxonomy, :with_parent, organization: evaluator_role.participatory_space.organization }
    evaluator_role { association :participatory_process_user_role, role: "evaluator" }
  end
end
