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

      # overrides for proposals
      config.to_prepare do
        ComponentValidator.include(Decidim::ReportingProposals::ComponentValidatorOverride)
      end

      initializer "decidim_reporting_proposals.overrides", after: "decidim.action_controller" do
        config.to_prepare do
          Decidim::Admin::ComponentsController.include(Decidim::ReportingProposals::Admin::NeedsHeaderSnippets)
          Decidim::Proposals::Admin::ProposalsController.include(Decidim::ReportingProposals::Admin::NeedsHeaderSnippets)
          Decidim::Proposals::Admin::ProposalsController.include(Decidim::ReportingProposals::Admin::ProposalsControllerOverride)
          Decidim::Proposals::Admin::ProposalsHelper.include(Decidim::ReportingProposals::Admin::ProposalsHelperOverride)
          Decidim::Proposals::ProposalsController.include(Decidim::ReportingProposals::ProposalsControllerOverride)
          Decidim::Proposals::ProposalWizardHelper.include(Decidim::ReportingProposals::ProposalWizardHelperOverride)
          Decidim::CreateReport.include(Decidim::ReportingProposals::CreateReportOverride)
          ComponentValidator.include(Decidim::ReportingProposals::ComponentValidatorOverride)
          Decidim::Map::Autocomplete::Builder.include(Decidim::ReportingProposals::MapBuilderOverride)
          Decidim::FormBuilder.include(Decidim::ReportingProposals::FormBuilderOverride)
          Decidim::Proposals::ProposalSerializer.include(Decidim::ReportingProposals::ProposalSerializerOverride)
          Decidim::User.include(Decidim::ReportingProposals::UserOverride)
          Decidim::Category.include(Decidim::ReportingProposals::CategoryOverride)
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
            settings.attribute(:unanswered_proposals_overdue, type: :integer, default: Decidim::ReportingProposals.unanswered_proposals_overdue)
            settings.attribute(:evaluating_proposals_overdue, type: :integer, default: Decidim::ReportingProposals.evaluating_proposals_overdue)
            settings.attribute(:proposal_photo_editing_enabled, type: :boolean, default: false)
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
