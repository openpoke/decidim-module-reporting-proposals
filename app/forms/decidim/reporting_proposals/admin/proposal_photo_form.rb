# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module Admin
      class ProposalPhotoForm < Decidim::Form
        include Decidim::AttachmentAttributes
        attribute :attachment, AttachmentForm
        attachments_attribute :photos
      end
    end
  end
end
