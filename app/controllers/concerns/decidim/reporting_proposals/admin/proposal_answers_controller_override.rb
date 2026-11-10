# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalAnswersControllerOverride
        extend ActiveSupport::Concern

        included do
          helper Decidim::Proposals::Admin::ProposalBulkActionsHelper

          before_action(only: :update) { @photo_form = form(Decidim::ReportingProposals::Admin::ProposalPhotoForm).instance }
        end
      end
    end
  end
end
