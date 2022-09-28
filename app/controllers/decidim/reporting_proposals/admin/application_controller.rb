# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::ApplicationController
        def permission_class_chain
          [::Decidim::ReportingProposals::Admin::Permissions] + super
        end
      end
    end
  end
end
