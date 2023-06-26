# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalsControllerOverride
      extend ActiveSupport::Concern
      include NeedsProposalExtraValidationsSnippets

      included do
        helper_method :reporting_proposal?, :geocoding_comparison?

        def new
          enforce_permission_to :create, :proposal
          @step = STEP1
          if proposal_draft.present?
            redirect_to edit_draft_proposal_path(proposal_draft, component_id: proposal_draft.component.id, question_slug: proposal_draft.component.participatory_space.slug)
          else
            @form = form(new_proposal_form).from_params(body: translated_proposal_body_template)
          end
        end

        def create
          enforce_permission_to :create, :proposal
          @step = STEP1
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

        # change comparison class if geocoding comparison is enabled
        def compare
          enforce_permission_to :edit, :proposal, proposal: @proposal
          @step = STEP2
          klass = if geocoding_comparison?
                    Decidim::ReportingProposals::NearbyProposals
                  else
                    Decidim::Proposals::SimilarProposals
                  end
          @similar_proposals ||= klass
                                 .for(current_component, @proposal)
                                 .all

          if @similar_proposals.blank?
            flash[:notice] = I18n.t("proposals.proposals.compare.no_similars_found", scope: "decidim")
            redirect_to "#{Decidim::ResourceLocatorPresenter.new(@proposal).path}/complete"
          end
        end

        # disable this step for reporting proposals
        def complete
          enforce_permission_to :edit, :proposal, proposal: @proposal
          @step = STEP3

          @form = form_proposal_model

          @form.attachment = form_attachment_new

          redirect_to "#{Decidim::ResourceLocatorPresenter.new(@proposal).path}/preview" if reporting_proposal?
        end

        def edit_draft
          @step = reporting_proposal? ? STEP1 : STEP3
          enforce_permission_to :edit, :proposal, proposal: @proposal
        end

        private

        def form_proposal_params
          form(edit_proposal_form).from_params(params)
        end

        def form_proposal_model
          form(edit_proposal_form).from_model(@proposal)
        end

        def edit_proposal_form
          reporting_proposal? ? Decidim::ReportingProposals::ProposalForm : Decidim::Proposals::ProposalForm
        end

        def new_proposal_form
          reporting_proposal? ? Decidim::ReportingProposals::ProposalForm : Decidim::Proposals::ProposalWizardCreateStepForm
        end

        def create_proposal_command
          reporting_proposal? ? CreateReportingProposal : Decidim::Proposals::CreateProposal
        end

        def reporting_proposal?
          component = current_component || @form.component
          component.manifest_name == "reporting_proposals"
        end

        def geocoding_comparison?
          if Decidim::Map.configured? && component_settings.geocoding_enabled? && component_settings.geocoding_comparison_enabled?
            @proposal ? @proposal.geocoded? : true
          end
        end
      end
    end
  end
end
