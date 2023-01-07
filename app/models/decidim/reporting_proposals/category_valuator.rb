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
    end
  end
end
