# frozen_string_literal: true

require "deface"

module Decidim
  module ReportingProposals
    # This is the engine that runs on the public interface of decidim-ReportingProposals.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ReportingProposals

      routes do
        post :locate, to: "geolocation#locate"
      end

      # generic overrides
      config.to_prepare do
        ComponentValidator.include(Decidim::ReportingProposals::ComponentValidatorOverride)
        Decidim::Category.include(Decidim::ReportingProposals::CategoryOverride)
        Decidim::FormBuilder.include(Decidim::ReportingProposals::FormBuilderOverride)
        Decidim::ResourceHelper.include(Decidim::ReportingProposals::ResourceHelperOverride)
        Decidim::Map::Autocomplete::Builder.include(Decidim::ReportingProposals::MapBuilderOverride)
        Decidim::CreateReport.include(Decidim::ReportingProposals::CreateReportOverride)
        Decidim::GalleryMethods.include(Decidim::ReportingProposals::GalleryMethodsOverride)
        Decidim::LinkedResourcesForCell.include(Decidim::ReportingProposals::LinkedResourcesForCellOverride)
        Decidim::Proposals::ProposalSerializer.include(Decidim::ReportingProposals::ProposalSerializerOverride)
        Decidim::Proposals::ProposalsPickerCell.include(Decidim::ReportingProposals::ProposalsPickerCellOverride)
        Decidim::Proposals::PublishProposal.include(Decidim::ReportingProposals::PublishProposalOverride)
        Decidim::Proposals::Admin::AnswerProposal.include(Decidim::ReportingProposals::Admin::AnswerProposalOverride)
        Decidim::Accountability::Admin::ResultForm.include(Decidim::ReportingProposals::MapIncludedProposalsForFormOverride)
        Decidim::Accountability::Admin::CreateResult.include(Decidim::ReportingProposals::Admin::CreateResultOverride)
        Decidim::Accountability::Admin::UpdateResult.include(Decidim::ReportingProposals::Admin::UpdateResultOverride)
        Decidim::Accountability::Admin::UpdateImportedResult.include(Decidim::ReportingProposals::Admin::UpdateResultOverride)
        Decidim::Meetings::CloseMeetingForm.include(Decidim::ReportingProposals::CloseMeetingFormOverride)
        Decidim::Meetings::Admin::CloseMeetingForm.include(Decidim::ReportingProposals::CloseMeetingFormOverride)
        Decidim::Meetings::Admin::CloseMeeting.include(Decidim::ReportingProposals::CloseMeetingOverride)
        Decidim::Meetings::CloseMeeting.include(Decidim::ReportingProposals::CloseMeetingOverride)
        Decidim::Budgets::Admin::ProjectForm.include(Decidim::ReportingProposals::MapIncludedProposalsForFormOverride)
        Decidim::Budgets::Admin::CreateProject.include(Decidim::ReportingProposals::CreateProjectOverride)
        Decidim::Budgets::Admin::UpdateProject.include(Decidim::ReportingProposals::CreateProjectOverride)
        Decidim::Templates::Admin::UpdateProposalAnswerTemplate.include(Decidim::ReportingProposals::Admin::UpdateProposalAnswerTemplateOverride) if defined?(Decidim::Templates)
        if defined?(Decidim::Elections::Admin::AnswerForm)
          Decidim::Elections::Admin::AnswerForm.include(Decidim::ReportingProposals::MapRelatedProposalsForFormOverride)
          Decidim::Elections::Admin::CreateAnswer.include(Decidim::ReportingProposals::Admin::CreateAnswerOverride)
          Decidim::Elections::Admin::UpdateAnswer.include(Decidim::ReportingProposals::Admin::CreateAnswerOverride)
        end
        Decidim::Admin::CategoryForm.include(Decidim::ReportingProposals::Admin::CategoryFormOverride)
        Decidim::Admin::CreateCategory.include(Decidim::ReportingProposals::Admin::CreateCategoryOverride)
        Decidim::Admin::UpdateCategory.include(Decidim::ReportingProposals::Admin::UpdateCategoryOverride)
        Decidim::Proposals::Admin::Permissions.include(Decidim::ReportingProposals::Admin::PermissionsOverride)
        Decidim::ParticipatorySpaceRoleConfig::Valuator.include(Decidim::ReportingProposals::ParticipatorySpaceRoleConfig::ValuatorOverride)

        # port of https://github.com/openpoke/decidim/pull/31,23,29,24,43
        Decidim::ReportedMailer.include(Decidim::ReportingProposals::ReportedMailerOverride)

        # since version 0.27 Decidim uses its own version of attribute validation (used to be Rectify::Forms)
        # To patch the ResourceManifest directly does not work now as the class is initialized by the proposals module on requiring the file component.rb
        # So we remove the manifest and create it again after patching the class ResourceManifest
        Decidim::ResourceManifest.include(Decidim::ReportingProposals::ResourceManifestOverride)
        Decidim.resource_manifests.delete(Decidim.find_resource_manifest(:proposal))
        component = Decidim.find_component_manifest(:proposals)
        component.register_resource(:proposal) do |resource|
          resource.model_class_name = "Decidim::Proposals::Proposal"
          resource.template = "decidim/proposals/proposals/linked_proposals"
          resource.card = "decidim/proposals/proposal"
          resource.reported_content_cell = "decidim/proposals/reported_content"
          resource.actions = %w(endorse vote amend comment vote_comment)
          resource.searchable = true
          resource.admin_route_name = "proposal"
        end
        component = Decidim.find_component_manifest(:reporting_proposals)
        component.register_resource(:reporting_proposal) do |resource|
          resource.model_class_name = "Decidim::Proposals::Proposal"
          resource.template = "decidim/proposals/proposals/linked_proposals"
          resource.card = "decidim/proposals/proposal"
          resource.reported_content_cell = "decidim/proposals/reported_content"
          resource.actions = %w(endorse vote amend comment vote_comment)
          resource.searchable = true
          resource.admin_route_name = "proposal"
        end
        Decidim::ResourceLocatorPresenter.include(Decidim::ReportingProposals::ResourceLocatorPresenterOverride)
        Decidim::Proposals::PublishProposalEvent.include(Decidim::ReportingProposals::PublishProposalEventOverride)
        Decidim::Proposals::Admin::AssignProposalsToValuator.include(Decidim::ReportingProposals::Admin::AssignProposalsToValuatorOverride)

        # Search user roles for different participatory spaces and apply override to all of them
        # We'll make sure this does not break rails in situations where database is not installed (ie, creating the test or development apps)
        begin
          Decidim.participatory_space_manifests.each do |manifest|
            manifest.model_class_name.constantize.new.user_roles.model.include(Decidim::ReportingProposals::ParticipatorySpaceUserRoleOverride)
          end
        rescue StandardError => e
          Rails.logger.error("Error while trying to include Decidim::ReportingProposals::ParticipatorySpaceUserRoleOverride: #{e.message}")
        end
      end

      # controllers and helpers overrides
      initializer "decidim_reporting_proposals.overrides", after: "decidim.action_controller" do
        config.to_prepare do
          Decidim::Admin::ComponentsController.include(Decidim::ReportingProposals::Admin::NeedsHeaderSnippets)
          Decidim::Admin::CategoriesController.include(Decidim::ReportingProposals::Admin::CategoriesControllerOverride)
          Decidim::Proposals::ProposalsController.include(Decidim::ReportingProposals::ProposalsControllerOverride)
          Decidim::Proposals::ProposalWizardHelper.include(Decidim::ReportingProposals::ProposalWizardHelperOverride)
          Decidim::Proposals::Admin::ProposalsController.include(Decidim::ReportingProposals::Admin::NeedsHeaderSnippets)
          Decidim::Proposals::Admin::ProposalsController.include(Decidim::ReportingProposals::Admin::ProposalsControllerOverride)
          Decidim::Proposals::Admin::ProposalAnswersController.include(Decidim::ReportingProposals::Admin::ProposalAnswersControllerOverride)
          Decidim::Proposals::Admin::ProposalsHelper.include(Decidim::ReportingProposals::Admin::ProposalsHelperOverride)

          # port of https://github.com/openpoke/decidim/pull/24
          Decidim::Proposals::Admin::ValuationAssignmentsController.include(Decidim::ReportingProposals::Admin::ValuationAssignmentsControllerOverride)

          begin
            Decidim::Templates::Admin::ProposalAnswerTemplatesController.include(Decidim::ReportingProposals::Admin::ProposalAnswerTemplatesControllerOverride)
          rescue StandardError => e
            Rails.logger.error("Error while trying to include Decidim::Templates::Admin::ProposalAnswerTemplatesControllerOverride: #{e.message}")
          end
        end
      end

      initializer "decidim_reporting_proposals.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ReportingProposals::Engine, at: "/reporting_proposals", as: "decidim_reporting_proposals"
        end
      end

      initializer "decidim_reporting_proposals.component_overdue_options" do
        Decidim.component_registry.find(:proposals).tap do |component|
          component.settings(:global) do |settings|
            settings.attribute :geocoding_comparison_enabled, type: :boolean, default: false
            settings.attribute :geocoding_comparison_radius, type: :integer, default: 30
            settings.attribute :geocoding_comparison_newer_than, type: :integer, default: 60
            settings.attribute(:unanswered_proposals_overdue, type: :integer, default: Decidim::ReportingProposals.unanswered_proposals_overdue)
            settings.attribute(:evaluating_proposals_overdue, type: :integer, default: Decidim::ReportingProposals.evaluating_proposals_overdue)
            settings.attribute(:proposal_photo_editing_enabled, type: :boolean, default: false)
          end
        end
      end

      initializer "decidim_reporting_proposals.event_subscriptions" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/decidim.events\.proposals\.(proposal_published|proposal_update_category)/) do |_event_name, data|
            Decidim::ReportingProposals::AssignProposalValuatorsJob.perform_later(data)
          end

          Decidim::EventsManager.subscribe("decidim.events.reports.resource_hidden") do |_event_name, data|
            Decidim::ReportingProposals::Admin::HiddenResourceMailer.notify_mail(
              data[:resource], data[:affected_users], data[:extra][:report_reasons]
            ).deliver_later
          end
        end
      end

      initializer "decidim_reporting_proposals.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_reporting_proposals.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ReportingProposals::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ReportingProposals::Engine.root}/app/views")
      end
    end
  end
end
