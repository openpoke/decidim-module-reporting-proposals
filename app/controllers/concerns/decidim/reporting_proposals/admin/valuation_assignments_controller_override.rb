# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module ValuationAssignmentsControllerOverride
        extend ActiveSupport::Concern

        included do
          def create
            enforce_permission_to :assign_to_valuator, :proposals
            @form = form(Decidim::Proposals::Admin::ValuationAssignmentForm).from_params(params)
            Decidim::Proposals::Admin::AssignProposalsToValuator.call(@form) do
              on(:ok) do |_proposal|
                flash[:notice] = I18n.t("valuation_assignments.create.success", scope: "decidim.proposals.admin")
                redirect_to after_add_evaluator_url
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("valuation_assignments.create.invalid", scope: "decidim.proposals.admin")
                redirect_to after_add_evaluator_url
              end
            end
          end

          def destroy
            @form = form(Decidim::Proposals::Admin::ValuationAssignmentForm).from_params(destroy_params)

            enforce_permission_to :unassign_from_valuator, :proposals, valuator: @form.valuator_user

            Decidim::Proposals::Admin::UnassignProposalsFromValuator.call(@form) do
              on(:ok) do |_proposal|
                flash.keep[:notice] = I18n.t("valuation_assignments.delete.success", scope: "decidim.proposals.admin")
                if current_user == @form.valuator_user
                  redirect_to EngineRouter.admin_proxy(current_component).root_path
                else
                  redirect_back fallback_location: EngineRouter.admin_proxy(current_component).root_path
                end
              end

              on(:invalid) do
                flash.keep[:alert] = I18n.t("valuation_assignments.delete.invalid", scope: "decidim.proposals.admin")
                redirect_back fallback_location: EngineRouter.admin_proxy(current_component).root_path
              end
            end
          end

          def after_add_evaluator_url
            return request.referer if request.referer.present? && request.referer =~ %r{manage/proposals/[0-9]+}

            EngineRouter.admin_proxy(current_component).root_path
          end
        end
      end
    end
  end
end
