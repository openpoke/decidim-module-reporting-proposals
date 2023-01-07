# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class CategoryValuator < ApplicationRecord
      self.table_name = "decidim_reporting_proposals_category_valuators"

      belongs_to :category,
                 foreign_key: "decidim_category_id",
                 class_name: "Decidim::Category"

      belongs_to :valuator_role,
                 polymorphic: true

      delegate :user, to: :valuator_role

      validate :category_belongs_to_same_participatory_space

      private

      def category_belongs_to_same_participatory_space
        return if category.participatory_space == valuator_role.participatory_space

        errors.add(:category, :invalid)
      end
    end
  end
end
