# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class ProposalPhotoForm < Decidim::Form
        include Decidim::AttachmentAttributes
        attribute :attachment, AttachmentForm
        attachments_attribute :photos

        validates :add_photos, presence: true

        def current_component
          @current_component ||= context&.current_component
        end
      end
    end
  end
end
