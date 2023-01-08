# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module UpdateCategoryOverride
        extend ActiveSupport::Concern

        included do
          def call
            return broadcast(:invalid) if form.invalid?

            transaction do
              update_category
              update_valuators
            end
            broadcast(:ok)
          end

          private

          def update_valuators
            category.category_valuators.destroy_all
            category.participatory_space.user_roles.where(id: form.valuator_ids).each do |valuator|
              Decidim::ReportingProposals::CategoryValuator.create!(category: category, valuator_role: valuator)
            end
          end
        end
      end
    end
  end
end
