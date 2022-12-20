# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module CategoryOverride
      extend ActiveSupport::Concern

      included do
        has_many :categories_valuators,
                 class_name: "Decidim::ReportingProposals::CategoryValuator",
                 foreign_key: :decidim_user_id,
                 dependent: :destroy

        has_many :users, through: :categories_valuators, class_name: "Decidim::Category", foreign_key: :decidim_user_id
      end
    end
  end
end
