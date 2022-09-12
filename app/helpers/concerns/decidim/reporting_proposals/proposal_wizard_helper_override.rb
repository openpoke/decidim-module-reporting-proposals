# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalWizardHelperOverride
      extend ActiveSupport::Concern

      included do
        def proposal_wizard_stepper(current_step)
          steps = %(
            #{proposal_wizard_stepper_step(:step_1, current_step)}
            #{proposal_wizard_stepper_step(:step_2, current_step)}
          )
          steps = %(#{steps} #{proposal_wizard_stepper_step(:step_3, current_step)}) unless reporting_proposals_component?
          steps = %(#{steps} #{proposal_wizard_stepper_step(:step_4, current_step)})

          content_tag :ol, class: "wizard__steps" do
            steps.html_safe
          end
        end

        private

        def total_steps
          reporting_proposals_component? ? 3 : 4
        end

        # rubocop:disable Rails/HelperInstanceVariable:
        def reporting_proposals_component?
          return unless @form&.component&.manifest_name

          @form.component.manifest_name == "reporting_proposals"
        end
        # rubocop:enable Rails/HelperInstanceVariable:
      end
    end
  end
end
