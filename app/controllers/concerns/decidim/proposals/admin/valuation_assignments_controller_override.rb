# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      module ValuationAssignmentsControllerOverride
        extend ActiveSupport::Concern

        included do
          def create
            enforce_permission_to :assign_to_valuator, :proposals
            @form = form(Admin::ValuationAssignmentForm).from_params(params)
            Admin::AssignProposalsToValuator.call(@form) do
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

          def after_add_evaluator_url
            return request.referer if request.referer.present? && request.referer =~ %r{manage/proposals/[0-9]+}

            EngineRouter.admin_proxy(current_component).root_path
          end
        end
      end
    end
  end
end
