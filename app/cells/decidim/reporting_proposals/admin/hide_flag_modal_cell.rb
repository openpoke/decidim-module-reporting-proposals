# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class HideFlagModalCell < Decidim::ViewModel
        include ActionView::Helpers::FormOptionsHelper
        include Decidim::LayoutHelper

        private

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
