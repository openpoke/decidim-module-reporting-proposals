# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      module AnswerProposalOverride
        extend ActiveSupport::Concern

        included do
          def call
            return broadcast(:invalid) if form.invalid?

            store_initial_proposal_state

            transaction do
              answer_proposal
              notify_proposal_answer
              send_email_to_author
            end

            broadcast(:ok)
          end

          private

          def send_email_to_author
            return unless Decidim::ReportingProposals.notify_authors_on_publish.include?(proposal.component.manifest_name.to_sym)

            affected_users.each do |user|
              Decidim::Proposals::Admin::NotificationAnswerProposalMailer.notify_proposal_author(proposal, user).deliver_later
            end
          end

          def affected_users
            proposal.notifiable_identities
          end
        end
      end
    end
  end
end
