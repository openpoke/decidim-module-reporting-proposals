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

        # there is a bug in decidim that does not clean records from ValuationAssignment when removing Space roles
        # This is a workaround to clean them manually
        # It might be possible that we need to change this when this is solved:
        # https://github.com/decidim/decidim/issues/10353
        has_many :proposal_valuation_assignments,
                 class_name: "Decidim::Proposals::ValuationAssignment",
                 foreign_key: :valuator_role_id,
                 dependent: :destroy
      end
    end
  end
end
