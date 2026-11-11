# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ProposalsControllerOverride
      extend ActiveSupport::Concern
      include NeedsProposalExtraValidationsSnippets

      included do
        helper_method :reporting_proposal?, :geocoding_comparison?

        before_action(only: :compare) { ensure_is_draft }

        # rubocop:disable Naming/VariableNumber
        STEP1 = :step_1
        STEP2 = :step_2
        STEP_COMPARE = :step_compare
        # rubocop:enable Naming/VariableNumber

        def new
          enforce_permission_to :create, :proposal
          @step = Proposals::ProposalsController::STEP1
          if proposal_draft.present?
            redirect_to edit_draft_proposal_path(proposal_draft, component_id: proposal_draft.component.id, question_slug: proposal_draft.component.participatory_space.slug)
          else
            @form = form(new_proposal_form).from_params(body: translated_proposal_body_template)
          end
        end

        def create
          enforce_permission_to :create, :proposal
          @step = Proposals::ProposalsController::STEP1
          @form = form(new_proposal_form).from_params(proposal_creation_params)

          Decidim::Proposals::CreateProposal.call(@form, current_user) do
            on(:ok) do |proposal|
              flash[:notice] = I18n.t("proposals.create.success", scope: "decidim")

              @proposal = proposal

              path = if geocoding_comparison?
                       "#{Decidim::ResourceLocatorPresenter.new(proposal).path}/compare"
                     else
                       "#{Decidim::ResourceLocatorPresenter.new(proposal).path}/preview"
                     end

              redirect_to path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("proposals.create.error", scope: "decidim")
              render :new, status: :unprocessable_content
            end
          end
        end

        def compare
          @step = Proposals::ProposalsController::STEP_COMPARE

          enforce_permission_to :edit, :proposal, proposal: @proposal

          @similar_proposals ||= Decidim::ReportingProposals::NearbyProposals.for(current_component, @proposal).all

          if @similar_proposals.blank?
            flash[:notice] = I18n.t("reporting_proposals.proposals.compare.no_similars_found", scope: "decidim")
            redirect_to "#{Decidim::ResourceLocatorPresenter.new(@proposal).path}/preview"
          end
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
          reporting_proposal? ? Decidim::ReportingProposals::ProposalForm : Decidim::Proposals::ProposalForm
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
