# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalWizardHelperOverride
      extend ActiveSupport::Concern

      included do
        def proposal_wizard_stepper(current_step)
          steps = %(
            #{proposal_wizard_stepper_step(ProposalsController::STEP1, current_step)}
            #{proposal_wizard_stepper_step(ProposalsController::STEP2, current_step)}
          )
          steps = %(#{steps} #{proposal_wizard_stepper_step(ProposalsController::STEP3, current_step)}) unless reporting_proposals_component?
          steps = %(#{steps} #{proposal_wizard_stepper_step(ProposalsController::STEP4, current_step)})

          content_tag :ol, class: "wizard__steps" do
            steps.html_safe
          end
        end

        def proposal_wizard_current_step_of(step)
          current_step_num = proposal_wizard_step_number(step)
          current_step_num = 3 if current_step_num == 4 && reporting_proposals_component?
          see_steps = content_tag(:span, class: "hide-for-large") do
            concat " ("
            concat content_tag :a, t(:"decidim.proposals.proposals.wizard_steps.see_steps"), "data-toggle": "steps"
            concat ")"
          end
          content_tag :span, class: "text-small" do
            concat t(:"decidim.proposals.proposals.wizard_steps.step_of", current_step_num: current_step_num, total_steps: total_steps)
            concat see_steps
          end
        end

        # rubocop:disable Rails/HelperInstanceVariable:
        def distance(meters = nil)
          meters = @proposal.component.settings.geocoding_comparison_radius.to_f if meters.nil?

          return "#{meters.round}m" if meters < 1000

          "#{(meters / 1000).round}Km"
        end

        private

        def total_steps
          reporting_proposals_component? ? 3 : 4
        end

        def reporting_proposals_component?
          return unless @form&.component&.manifest_name

          @form.component.manifest_name == "reporting_proposals"
        end
        # rubocop:enable Rails/HelperInstanceVariable:
      end
    end
  end
end
