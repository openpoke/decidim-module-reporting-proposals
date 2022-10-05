# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # This is the engine that runs on the public interface of `ReportingProposals`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ReportingProposals::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        put :hide_proposal, to: "proposals#hide_proposal"
        post :photos_proposal, to: "proposals#photos_proposal"
      end

      initializer "decidim_reporting_proposals.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ReportingProposals::AdminEngine, at: "/admin/reporting_proposals", as: "decidim_admin_reporting_proposals"
        end
      end

      def load_seed
        nil
      end
    end
  end
end
