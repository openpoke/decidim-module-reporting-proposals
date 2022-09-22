# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      include Decidim::CreateReport
      include Decidim::Admin::HideResource
    end
  end
end
