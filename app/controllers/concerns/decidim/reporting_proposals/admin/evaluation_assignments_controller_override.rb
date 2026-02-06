# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module EvaluationAssignmentsControllerOverride
        extend ActiveSupport::Concern

        included do
          def create
            @form = form(Decidim::Proposals::Admin::EvaluationAssignmentForm).from_params(params)

            @form.proposals.each do |proposal|
              enforce_permission_to :assign_to_evaluator, :proposals, proposal:
            end

            Decidim::Proposals::Admin::AssignProposalsToEvaluator.call(@form) do
              on(:ok) do |_proposal|
                flash[:notice] = I18n.t("evaluation_assignments.create.success", scope: "decidim.proposals.admin")
                redirect_to after_add_evaluator_url
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("evaluation_assignments.create.invalid", scope: "decidim.proposals.admin")
                redirect_to after_add_evaluator_url
              end
            end
          end

          def destroy
            @form = form(Decidim::Proposals::Admin::EvaluationAssignmentForm).from_params(params)

            @form.evaluator_roles.each do |evaluator_role|
              enforce_permission_to :unassign_from_evaluator, :proposals, evaluator: evaluator_role.user
            end

            Decidim::Proposals::Admin::UnassignProposalsFromEvaluator.call(@form) do
              on(:ok) do |_proposal|
                flash.keep[:notice] = I18n.t("evaluation_assignments.delete.success", scope: "decidim.proposals.admin")
                if @form.valuator_roles.map(&:user).include?(current_user)
                  redirect_to EngineRouter.admin_proxy(current_component).root_path
                else
                  redirect_back fallback_location: EngineRouter.admin_proxy(current_component).root_path
                end
              end

              on(:invalid) do
                flash.keep[:alert] = I18n.t("evaluation_assignments.delete.invalid", scope: "decidim.proposals.admin")
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
