# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module CategoriesControllerOverride
        extend ActiveSupport::Concern

        included do
          helper Decidim::Proposals::Admin::ProposalBulkActionsHelper
        end
      end
    end
  end
end
