# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ParticipatorySpaceUserRoleOverride
      extend ActiveSupport::Concern

      included do
        has_many :category_valuators,
                 class_name: "Decidim::ReportingProposals::CategoryValuator",
                 foreign_key: :valuator_role_id,
                 dependent: :destroy
      end
    end
  end
end
