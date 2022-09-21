# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalsControllerOverride
      extend ActiveSupport::Concern

      included do
        def new
          enforce_permission_to :create, :proposal
          @step = :step_1
          if proposal_draft.present?
            redirect_to edit_draft_proposal_path(proposal_draft, component_id: proposal_draft.component.id, question_slug: proposal_draft.component.participatory_space.slug)
          else
            @form = form(new_proposal_form).from_params(body: translated_proposal_body_template)
          end
        end

        def create
          enforce_permission_to :create, :proposal
          @step = :step_1
          @form = form(new_proposal_form).from_params(proposal_creation_params)

          create_proposal_command.call(@form, current_user) do
            on(:ok) do |proposal|
              flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")

              redirect_to "#{Decidim::ResourceLocatorPresenter.new(proposal).path}/compare"
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
              render :new
            end
          end
        end

        def complete
          enforce_permission_to :edit, :proposal, proposal: @proposal
          @step = :step_3

          @form = form_proposal_model

          @form.attachment = form_attachment_new

          redirect_to "#{Decidim::ResourceLocatorPresenter.new(@proposal).path}/preview" if reporting_proposals?
        end

        private

        def new_proposal_form
          reporting_proposals? ? Decidim::Proposals::ProposalForm : Decidim::Proposals::ProposalWizardCreateStepForm
        end

        def create_proposal_command
          reporting_proposals? ? CreateReportingProposal : Decidim::Proposals::CreateProposal
        end

        def reporting_proposals?
          component = current_component || @form.component
          component.manifest_name == "reporting_proposals"
        end
      end
    end
  end
end
