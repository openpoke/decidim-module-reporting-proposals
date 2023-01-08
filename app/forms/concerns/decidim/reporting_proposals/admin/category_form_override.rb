# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      module CategoryFormOverride
        extend ActiveSupport::Concern

        included do
          attribute :valuator_ids, Array[Integer]

          def map_model(model)
            self.valuator_ids = model.category_valuators.pluck(:valuator_role_id)
          end
        end
      end
    end
  end
end
