# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class ReportAndHideProposal < Rectify::Command
      def initialize(form, reportable, current_user)
        @form = form
        @reportable = reportable
        @current_user = current_user
      end
    end
  end
end
