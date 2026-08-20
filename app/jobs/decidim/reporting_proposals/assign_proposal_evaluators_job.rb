# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class AssignProposalEvaluatorsJob < ApplicationJob
      queue_as :default
      attr_reader :resource

      def perform(data)
        @resource = data[:resource]
        return unless relevant_event?(data)
        return if evaluator_roles.blank?

        evaluator_names = evaluator_roles.map { |role| role.user.name }.join(", ")
        Decidim::Proposals::Admin::AssignProposalsToEvaluator.call(form) do
          on(:ok) do
            Rails.logger.info("Automatically assigned evaluators #{evaluator_names} to proposal ##{resource.id}")
          end
          on(:invalid) do
            Rails.logger.warn("Couldn't automatically assign evaluators #{evaluator_names} to proposal ##{resource.id}")
          end
        end
      end

      private

      # the publish event is notified several times; act only on the space-level, non-admin one
      def relevant_event?(data)
        return true if data[:event_class] == "Decidim::Proposals::UpdateProposalTaxonomiesEvent"

        data[:extra][:participatory_space].present? && data[:extra][:type] != "admin"
      end

      def evaluator_roles
        @evaluator_roles ||= begin
          role_ids = TaxonomyEvaluator.assignments_for(resource.taxonomies, space_evaluator_roles)
                                      .values.flatten.map(&:evaluator_role_id).uniq
          space_evaluator_roles.where(id: role_ids).order_by_name
        end
      end

      # assembly user roles include the ancestor assemblies ones, so a strict space check is needed
      def space_evaluator_roles
        @space_evaluator_roles ||= participatory_space.user_roles(:evaluator).for_space(participatory_space)
      end

      def participatory_space
        @participatory_space ||= resource.component.participatory_space
      end

      def form
        Decidim::Proposals::Admin::EvaluationAssignmentForm.from_params(
          evaluator_role_ids: evaluator_roles.map(&:id),
          proposal_ids: [resource.id]
        ).with_context(
          current_component: resource.component,
          current_user: automation_user
        )
      end

      # bot user used only for traceability, so the admin log attributes the
      # assignment to "Automatic assignment" instead of a real admin
      def automation_user
        @automation_user ||= find_automation_user || create_automation_user
      end

      def find_automation_user
        resource.organization.users.not_deleted.not_managed.find_by(email: Decidim::ReportingProposals.automation_user_email)
      end

      def create_automation_user
        name = "Automatic assignment"
        password = SecureRandom.hex(20)
        Decidim::User.create!(
          organization: resource.organization,
          email: Decidim::ReportingProposals.automation_user_email,
          name:,
          nickname: Decidim::User.nicknamize(name, resource.organization.id),
          password:,
          password_confirmation: password,
          tos_agreement: true,
          &:skip_confirmation!
        )
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
        # another job created the bot concurrently
        find_automation_user
      end
    end
  end
end
