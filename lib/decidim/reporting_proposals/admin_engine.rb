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

      initializer "decidim_reporting_proposals.taxonomy_evaluators_routes" do
        Decidim::ParticipatoryProcesses::AdminEngine.routes.append do
          scope "/participatory_processes/:participatory_process_slug" do
            resources :taxonomy_evaluators, only: [:index, :edit, :update],
                                            controller: "/decidim/reporting_proposals/admin/participatory_process_taxonomy_evaluators"
          end
        end

        if defined?(Decidim::Assemblies::AdminEngine)
          Decidim::Assemblies::AdminEngine.routes.append do
            scope "/assemblies/:assembly_slug" do
              resources :taxonomy_evaluators, only: [:index, :edit, :update],
                                              controller: "/decidim/reporting_proposals/admin/assembly_taxonomy_evaluators"
            end
          end
        end
      end

      initializer "decidim_reporting_proposals.taxonomy_evaluators_menus" do
        Decidim.menu :admin_participatory_process_menu do |menu|
          menu.add_item :taxonomy_evaluators,
                        I18n.t("menu.taxonomy_evaluators", scope: "decidim.reporting_proposals.admin"),
                        decidim_admin_participatory_processes.taxonomy_evaluators_path(current_participatory_space),
                        active: is_active_link?(decidim_admin_participatory_processes.taxonomy_evaluators_path(current_participatory_space)),
                        icon_name: "price-tag-3-line",
                        if: allowed_to?(:update, :taxonomy_evaluator)

          menu.move :taxonomy_evaluators, after: :components
        end

        if defined?(Decidim::Assemblies::AdminEngine)
          Decidim.menu :admin_assembly_menu do |menu|
            menu.add_item :taxonomy_evaluators,
                          I18n.t("menu.taxonomy_evaluators", scope: "decidim.reporting_proposals.admin"),
                          decidim_admin_assemblies.taxonomy_evaluators_path(current_participatory_space),
                          active: is_active_link?(decidim_admin_assemblies.taxonomy_evaluators_path(current_participatory_space)),
                          icon_name: "price-tag-3-line",
                          if: allowed_to?(:update, :taxonomy_evaluator)

            menu.move :taxonomy_evaluators, after: :components
          end
        end
      end

      initializer "decidim_reporting_proposals.register_icons" do
        Decidim.icons.register(name: "camera-line", icon: "camera-line", category: "system", description: "", engine: :decidim_reporting_proposals)
        Decidim.icons.register(name: "corner-down-right-line", icon: "corner-down-right-line", category: "system", description: "", engine: :decidim_reporting_proposals)
      end

      def load_seed
        nil
      end
    end
  end
end
