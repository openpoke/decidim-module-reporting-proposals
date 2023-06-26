# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Exposes the proposal resource so users can view and create them.
    module ComponentValidatorOverride
      extend ActiveSupport::Concern

      included do
        # The actual validator method. It is called when ActiveRecord iterates
        # over all the validators.
        def validate_each(record, attribute, component)
          unless component
            record.errors.add(attribute, :blank)
            return
          end
          manifests = [options[:manifest].to_s]
          manifests << "reporting_proposals" if manifests.first == "proposals"

          record.errors.add(attribute, :invalid) unless component.manifest_name.to_s.in?(manifests)
        end
      end
    end
  end
end
