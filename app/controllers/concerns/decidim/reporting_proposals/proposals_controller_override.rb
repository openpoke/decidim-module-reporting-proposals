# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalsControllerOverride
      extend ActiveSupport::Concern

      included do
        def complete
          enforce_permission_to :edit, :proposal, proposal: @proposal
          @step = :step_3

          @form = form_proposal_model

          @form.attachment = form_attachment_new

          redirect_to "#{Decidim::ResourceLocatorPresenter.new(@proposal).path}/preview" if @form.component.manifest_name == "reporting_proposals"
        end
      end
    end
  end
end
