# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module CategoryFormOverride
        extend ActiveSupport::Concern

        included do
          attribute :valuators
        end
      end
    end
  end
end
