# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class ProposalPhotoForm < Decidim::Form
        include Decidim::AttachmentAttributes
        attribute :attachment, AttachmentForm
        attachments_attribute :photos

        def current_component
          @current_component ||= @proposal&.component
        end
      end
    end
  end
end
