# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module UserOverride
      extend ActiveSupport::Concern

      included do
        has_many :categories_valuators,
                 class_name: "Decidim::ReportingProposals::CategoryValuator",
                 foreign_key: :decidim_category_id,
                 dependent: :destroy

        has_many :valuator_categories, through: :categories_valuators, class_name: "Decidim::Category", foreign_key: :decidim_category_id, source: :category
      end
    end
  end
end
