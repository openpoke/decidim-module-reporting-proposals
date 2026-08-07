# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ReportingProposals
    module Admin
      describe ProposalPhotoForm do
        subject { described_class.from_params(params).with_context(context) }

        let(:organization) { create(:organization) }
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:component) { create(:reporting_proposals_component, participatory_space:) }
        let(:add_attachments) { [Decidim::Dev.test_file("city.jpeg", "image/jpeg")] }
        let(:params) { { add_attachments: } }
        let(:context) { { current_component: component, current_organization: organization } }

        it { is_expected.to be_valid }

        context "when there are no attachments" do
          let(:add_attachments) { [] }

          it { is_expected.not_to be_valid }
        end

        # The browser always submits the blank hidden input of the multiple file field
        context "when the attachments field is submitted empty" do
          let(:add_attachments) { [""] }

          it { is_expected.not_to be_valid }
        end

        context "when a document is uploaded" do
          let(:add_attachments) { [Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")] }

          it { is_expected.not_to be_valid }

          it "adds an error on add_attachments" do
            subject.valid?
            expect(subject.errors[:add_attachments]).to include("must contain only images")
          end
        end

        context "when mixing an image and a document" do
          let(:add_attachments) { [Decidim::Dev.test_file("city.jpeg", "image/jpeg"), Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")] }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
