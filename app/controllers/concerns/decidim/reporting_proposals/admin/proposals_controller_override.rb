# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # Exposes the proposal resource so users can view and create them.
      module ProposalsControllerOverride
        extend ActiveSupport::Concern

        included do
          helper_method :reporting_proposal?, :proposals, :query, :form_presenter, :proposal, :proposal_ids
          def show
            enforce_permission_to :show, :proposal, proposal: proposal

            @notes_form = form(Decidim::Proposals::Admin::ProposalNoteForm).instance
            @answer_form = form(Decidim::Proposals::Admin::ProposalAnswerForm).from_model(proposal)
            @photo_form = form(Decidim::ReportingProposals::Admin::ProposalPhotoForm).instance
          end

          private

          def reporting_proposal?
            component = current_component || @photo_form.current_component
            component.manifest_name == "reporting_proposals"
          end
        end
      end
    end
  end
end
