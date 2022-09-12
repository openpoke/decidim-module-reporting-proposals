# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # This is the engine that runs on the public interface of decidim-ReportingProposals.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ReportingProposals

      # overrides for proposals
      config.after_initialize do
        Decidim::Admin::ComponentsController.include(Decidim::ReportingProposals::Admin::NeedsHeaderSnippets)
        Decidim::Proposals::ProposalsController.include(Decidim::ReportingProposals::ProposalsControllerOverride)
        Decidim::Proposals::ProposalWizardHelper.include(Decidim::ReportingProposals::ProposalWizardHelperOverride)
        ComponentValidator.include(Decidim::ReportingProposals::ComponentValidatorOverride)
      end

      initializer "decidim_reporting_proposals.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
