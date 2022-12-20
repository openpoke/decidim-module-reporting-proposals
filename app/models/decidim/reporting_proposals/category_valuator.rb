# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class CategoryValuator < ApplicationRecord
      self.table_name = "decidim_categories_valuators"

      belongs_to :category,
                 foreign_key: "decidim_category_id",
                 class_name: "Decidim::Category",
                 polymorphic: true

      belongs_to :user,
                 foreign_key: "decidim_user_id",
                 class_name: "Decidim::User"
    end
  end
end
