# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module CategoryOverride
      extend ActiveSupport::Concern

      included do
        has_many :category_valuators,
                 class_name: "Decidim::ReportingProposals::CategoryValuator",
                 foreign_key: :decidim_category_id,
                 dependent: :destroy

        def valuator_roles
          category_valuators.map(&:valuator_role)
        end

        def valuator_users
          category_valuators.map(&:user)
        end

        def valuator_names
          valuator_users.map(&:name)
        end
      end
    end
  end
end
