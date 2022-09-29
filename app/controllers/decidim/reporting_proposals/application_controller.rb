# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class ApplicationController < Decidim::ApplicationController
      def permission_class_chain
        [::Decidim::ReportingProposals::Permissions] + super
      end
    end
  end
end
