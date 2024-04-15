# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe NotificationPublishProposalMailer do
    include ActionView::Helpers::SanitizeHelper

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:proposals_component) { create(:component, manifest_name: "proposals", participatory_space: participatory_process) }
    let(:reporting_proposals_component) { create(:component, manifest_name: "reporting_proposals", participatory_space: participatory_process) }
    let(:users) { create_list(:user, 3, organization:) }
    let(:proposal) { create(:proposal, component: proposals_component, users:) }
    let(:reporting_proposal) { create(:proposal, component: reporting_proposals_component) }

    def proposal_url(proposal)
      Decidim::ResourceLocatorPresenter.new(proposal).url
    end

    context "when proposal component enabled" do
      before do
        Decidim::ReportingProposals.notify_authors_on_publish = [:proposals]
      end

      it "sends email to all users" do
        users.each do |user|
          mail = described_class.notify_proposal_author(proposal, user)
          expect(mail.subject).to eq("Your proposal has been published")
          expect(mail.from).to eq([Decidim::Organization.first.smtp_settings["from"]])
          expect(mail.to).to eq([user.email])
          expect(mail.body.encoded).to include(proposal_url(proposal))
        end
      end

      it "does not send email for reporting_proposal component" do
        users.each do |user|
          expect do
            described_class.notify_proposal_author(reporting_proposal, user)
          end.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end
    end

    context "when reporting_proposal component enabled" do
      before do
        Decidim::ReportingProposals.notify_authors_on_publish = [:reporting_proposals]
      end

      it "sends email to all users" do
        users.each do |user|
          mail = described_class.notify_proposal_author(reporting_proposal, user)
          expect(mail.subject).to eq("Your proposal has been published")
          expect(mail.from).to eq([Decidim::Organization.first.smtp_settings["from"]])
          expect(mail.to).to eq([user.email])
          expect(mail.body.encoded).to include(proposal_url(reporting_proposal))
        end
      end

      it "does not send email for proposal component" do
        users.each do |user|
          expect do
            described_class.notify_proposal_author(proposal, user)
          end.not_to change(ActionMailer::Base.deliveries, :count)
        end
      end
    end
  end
end
