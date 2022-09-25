# frozen_string_literal: true

module Decidim
    module ReportingProposals
      module Admin
      class HideFlagModalCell < Decidim::ViewModel
        include ActionView::Helpers::FormOptionsHelper
        include Decidim::LayoutHelper
        include Decidim::ReportingProposals::Engine.routes.url_helpers
        include Decidim::ResourceHelper

        property :moderation

        def cache_hash
          hash = []
          hash.push(I18n.locale)
          hash.push(current_user.try(:id))
          hash.push(model.reported_by?(current_user) ? 1 : 0)
          hash.push(model.class.name.gsub("::", ":"))
          hash.push(model.id)
          hash.join(Decidim.cache_key_separator)
        end

        def show
          render
        end

        private

        def user_report_form
          Decidim::ReportForm.from_params(reason: "spam")
        end

        def modal_id
          options[:modal_id] || "flagModal"
        end

        def report_form
          @report_form ||= Decidim::ReportForm.new(reason: "spam")
        end
      end
    end
  end
end
