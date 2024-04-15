# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe HiddenResourceMailer do
    # include ActionView::Helpers::SanitizeHelper

    let!(:proposal) { create(:proposal) }
    let(:reason) { ["This is a reason", "This is another reason"] }

    context "when valuator assigned" do
      let(:mail) { described_class.notify_mail(proposal, proposal.authors, reason) }

      it "set subject email" do
        expect(mail.subject).to eq("Your proposal has been hidden")
      end

      it "set email from" do
        expect(mail.from).to eq([Decidim::Organization.first.smtp_settings["from"]])
      end

      it "set email to" do
        expect(mail.to).to eq([proposal.authors.first.email])
      end

      it "body email has valuator name" do
        expect(email_body(mail)).to include("This is a reason")
        expect(email_body(mail)).to include("This is another reason")
      end

      it "body email has proposal links" do
        expect(email_body(mail)).to have_content(translated(proposal.title))
      end
    end
  end
end
