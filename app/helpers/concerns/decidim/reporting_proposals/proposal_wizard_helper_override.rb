# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalWizardHelperOverride
      extend ActiveSupport::Concern

      included do
        def proposal_wizard_steps
          [Proposals::ProposalsController::STEP1, Proposals::ProposalsController::STEP2]
          # steps << Proposals::ProposalsController::STEP4
        end

        def distance(meters = nil)
          meters = @proposal.component.settings.geocoding_comparison_radius.to_f if meters.nil?

          return "#{meters.round}m" if meters < 1000

          "#{(meters / 1000).round}Km"
        end

        private

        def total_steps
          proposal_wizard_steps.count
        end

        def reporting_proposals_component?
          return false unless current_component&.manifest_name

          current_component.manifest_name == "reporting_proposals"
        end
      end
    end
  end
end
