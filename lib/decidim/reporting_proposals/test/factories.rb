# frozen_string_literal: true

FactoryBot.define do
  factory :reporting_proposals_component, parent: :proposal_component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :reporting_proposals).i18n_name }
    manifest_name { :reporting_proposals }
  end
end
