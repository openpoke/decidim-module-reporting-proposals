# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class CreateReportingProposal < Decidim::Proposals::CreateProposal
      include ::Decidim::MultipleAttachmentsMethods
      include ::Decidim::Proposals::GalleryMethods

      def prepare_attachments
        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        if process_gallery?
          build_gallery
          return broadcast(:invalid) if gallery_invalid?
        end
      end

      def save_attachments
        @attached_to = @proposal
        create_gallery if process_gallery?
        create_attachments if process_attachments?
      end

      def create_proposal
        prepare_attachments

        PaperTrail.request(enabled: false) do
          @proposal = Decidim.traceability.perform_action!(
            :create,
            Decidim::Proposals::Proposal,
            @current_user,
            visibility: "public-only"
          ) do
            proposal = Decidim::Proposals::Proposal.new(
              title: {
                I18n.locale => title_with_hashtags
              },
              body: {
                I18n.locale => body_with_hashtags
              },
              category: form.category,
              scope: form.scope,
              address: form.address,
              latitude: form.latitude,
              longitude: form.longitude,
              component: form.component
            )
            proposal.add_coauthor(@current_user, user_group: user_group)
            proposal.save!
            proposal
          end
        end

        save_attachments
      end
    end
  end
end
