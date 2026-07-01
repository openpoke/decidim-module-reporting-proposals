# frozen_string_literal: true

module Decidim
  module ReportingProposals
    class CreateReportingProposal < Decidim::Proposals::CreateProposal
      include ::Decidim::MultipleAttachmentsMethods
      include Decidim::ReportingProposals::PhotoMethods

      def call
        return broadcast(:invalid) if form.invalid?

        if process_attachments?
          build_attachments
          return broadcast(:invalid) if attachments_invalid?
        end

        if process_photos?
          build_photos
          return broadcast(:invalid) if photos_invalid?
        end

        if proposal_limit_reached?
          form.errors.add(:base, I18n.t("decidim.proposals.new.limit_reached"))
          return broadcast(:invalid)
        end

        transaction do
          create_reporting_proposal

          @attached_to = @proposal
          create_photos if process_photos?
          create_attachments if process_attachments?
        end

        broadcast(:ok, proposal)
      end

      private

      def create_reporting_proposal
        PaperTrail.request(enabled: false) do
          @proposal = Decidim.traceability.perform_action!(
            :create,
            Decidim::Proposals::Proposal,
            @current_user,
            visibility: "public-only"
          ) do
            proposal = Decidim::Proposals::Proposal.new(
              title: {
                I18n.locale => Decidim::ContentProcessor.parse(form.title, current_organization: form.current_organization).rewrite
              },
              body: {
                I18n.locale => Decidim::ContentProcessor.parse_with_processor(:inline_images, form.body, current_organization: form.current_organization).rewrite
              },
              address: form.address,
              latitude: form.latitude,
              longitude: form.longitude,
              component: form.component
            )
            proposal.taxonomizations = form.taxonomizations if form.taxonomizations.present?
            proposal.add_coauthor(@current_user)
            proposal.save!
            proposal
          end
        end
      end
    end
  end
end
