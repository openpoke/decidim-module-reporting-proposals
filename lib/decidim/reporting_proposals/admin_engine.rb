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
        post :add_photos, to: "proposals#add_photos"
        delete :remove_photo, to: "proposals#remove_photo"
        resources :proposals do
          resources :proposal_notes, only: [:edit, :update]
          post :proposal_notes, to: "proposal_notes#update"
        end
      end

      initializer "decidim_reporting_proposals.admin_mount_routes" do
        Decidim::Admin::Engine.routes do
          mount Decidim::ReportingProposals::AdminEngine, at: "/reporting_proposals", as: "decidim_admin_reporting_proposals"
        end
      end

      def load_seed
        nil
      end
    end
  end
end
