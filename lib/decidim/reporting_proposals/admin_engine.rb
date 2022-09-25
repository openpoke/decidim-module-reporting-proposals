# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ReportingProposals::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :reporting_proposals, controller: "proposals_manager_controller" do
          patch :hide, on: :member
        end

        root to: "proposals#index"
      end

      initializer "decidim_reporting_proposals_admin.mount_routes", before: "decidim_admin.mount_routes" do
        # Mount the engine routes to Decidim::Core::Engine because otherwise
        # they would not get mounted properly.
        Decidim::Admin::Engine.routes.append do
          mount Decidim::ReportingProposals::Admin::Engine => "/"
        end
      end
    end
  end
end
