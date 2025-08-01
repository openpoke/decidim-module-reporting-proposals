# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalWizardHelperOverride
      extend ActiveSupport::Concern

      included do
        def proposal_wizard_steps
          steps = [Proposals::ProposalsController::STEP1]
          steps << Proposals::ProposalsController::STEP_COMPARE if reporting_proposals_component?
          steps << Proposals::ProposalsController::STEP2
        end

        # rubocop:disable Rails/HelperInstanceVariable
        def distance(meters = nil)
          meters = @proposal.component.settings.geocoding_comparison_radius.to_f if meters.nil?

          return "#{meters.round}m" if meters < 1000

          "#{(meters / 1000).round}Km"
        end
        # rubocop:enable Rails/HelperInstanceVariable

        private

        def proposal_wizard_aside_link_to_back(step)
          # byebug
          case step
          when Decidim::Proposals::ProposalsController::STEP1
            proposals_path
          when Decidim::Proposals::ProposalsController::STEP_COMPARE
            compare_proposal_path
          when Decidim::Proposals::ProposalsController::STEP2
            preview_proposal_path
          end
        end

        def total_steps
          proposal_wizard_steps.count
        end

        def reporting_proposals_component?
          return unless current_component&.manifest_name

          current_component.manifest_name == "reporting_proposals"
        end
      end
    end
  end
end
