# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::ReportingProposals::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :reporting_proposals do
          resources :proposals do
            member do
              put :hide
            end
          end
        end
      end
    end
  end
end
