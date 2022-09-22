# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # This is the engine that runs on the public interface of decidim-ReportingProposals.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ReportingProposals

      # overrides for proposals
      config.to_prepare do
        ComponentValidator.include(Decidim::ReportingProposals::ComponentValidatorOverride)
      end

      initializer "decidim_reporting_proposals.overrides", after: "decidim.action_controller" do
        config.to_prepare do
          Decidim::Admin::ComponentsController.include(Decidim::ReportingProposals::Admin::NeedsHeaderSnippets)
          Decidim::Proposals::Admin::ProposalsController.include(Decidim::ReportingProposals::Admin::NeedsHeaderSnippets)
          Decidim::Proposals::Admin::ProposalsHelper.include(Decidim::ReportingProposals::Admin::ProposalsHelperOverride)
          Decidim::Proposals::ProposalsController.include(Decidim::ReportingProposals::ProposalsControllerOverride)
          Decidim::Proposals::ProposalWizardHelper.include(Decidim::ReportingProposals::ProposalWizardHelperOverride)
        end
      end

      initializer "decidim_reporting_proposals.component_overdue_options" do
        Decidim.component_registry.find(:proposals).tap do |component|
          component.settings(:global) do |settings|
            settings.attribute(:unanswered_proposals_overdue, type: :integer, default: Decidim::ReportingProposals.unanswered_proposals_overdue)
            settings.attribute(:evaluating_proposals_overdue, type: :integer, default: Decidim::ReportingProposals.evaluating_proposals_overdue)
          end
        end
      end

      initializer "decidim_reporting_proposals.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
