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
        resources :proposal_notes, only: :update
      end

      initializer "decidim_reporting_proposals.template_routes" do
        if defined? Decidim::Templates::AdminEngine
          Decidim::Templates::AdminEngine.routes do
            resources :proposal_answer_templates do
              member do
                post :copy
              end
              collection do
                get :fetch
              end
            end
          end
        end
      end

      initializer "decidim_reporting_proposals.admin_mount_routes" do
        Decidim::Admin::Engine.routes do
          mount Decidim::ReportingProposals::AdminEngine, at: "/reporting_proposals", as: "decidim_admin_reporting_proposals"
        end
      end

      initializer "decidim_reporting_proposals.register_icons" do
        Decidim.icons.register(name: "camera-line", icon: "camera-line", category: "system", description: "", engine: :decidim_reporting_proposals)
      end

      def load_seed
        nil
      end
    end
  end
end
