# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalsControllerOverride
        extend ActiveSupport::Concern

        included do
          def show
            @notes_form = form(Decidim::Proposals::Admin::ProposalNoteForm).instance
            @answer_form = form(Decidim::Proposals::Admin::ProposalAnswerForm).from_model(proposal)
            @photo_form = form(Decidim::ReportingProposals::Admin::ProposalPhotoForm).instance
          end
        end
      end
    end
  end
end
