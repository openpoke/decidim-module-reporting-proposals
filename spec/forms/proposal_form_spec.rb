# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ReportingProposals
    describe ProposalForm do
      subject { described_class.from_params(params).with_context(context) }

      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
      let(:component) { create(:reporting_proposals_component, participatory_space:) }
      let(:title) { "More sidewalks and less roads!" }
      let(:body) { "Everything would be better" }
      let(:body_template) { nil }
      let(:author) { create(:user, organization:) }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let(:has_no_address) { false }
      let(:has_no_attachments) { false }
      let(:address) { "Some address" }
      let(:image) { [Decidim::Dev.test_file("city.jpeg", "image/jpeg")] }
      let(:attachment_params) { nil }
      let(:meeting_as_author) { false }
      let(:taxonomies) { [] }
      let(:params) do
        {
          title:,
          body:,
          body_template:,
          taxonomies:,
          author:,
          address:,
          latitude:,
          longitude:,
          has_no_address:,
          has_no_attachments:,
          add_attachments: image,
          meeting_as_author:,
          attachment: attachment_params
        }
      end
      let(:context) do
        {
          current_component: component,
          current_organization: component.organization,
          current_participatory_space: participatory_space
        }
      end

      before do
        stub_geocoding(address, [latitude, longitude])
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }

        it "form returns all values" do
          expect(subject.title).to eq(title)
          expect(subject.body).to eq(body)
          expect(subject.address).to eq(address)
          expect(subject.latitude).to eq(latitude)
          expect(subject.longitude).to eq(longitude)
        end
      end

      context "when there's no address" do
        let(:address) { nil }
        let(:latitude) { nil }
        let(:longitude) { nil }

        it { is_expected.not_to be_valid }

        context "and address is not required" do
          let(:has_no_address) { true }

          it { is_expected.to be_valid }
        end
      end

      context "when there are no attachments" do
        let(:image) { nil }

        it { is_expected.not_to be_valid }

        it "reports the error on the attribute rendered outside the upload modal" do
          expect(subject).not_to be_valid
          expect(subject.errors[:attachments]).to be_present
        end

        context "and attachments are not required" do
          let(:has_no_attachments) { true }

          it { is_expected.to be_valid }
        end
      end

      context "when the attachments field is submitted empty" do
        let(:image) { [""] }

        it { is_expected.not_to be_valid }

        context "and attachments are not required" do
          let(:has_no_attachments) { true }

          it { is_expected.to be_valid }
        end
      end

      context "when editing an existing proposal" do
        subject { described_class.from_model(proposal).with_context(context) }

        let!(:proposal) { create(:proposal, attachments:, component:) }
        let(:attachments) { [create(:attachment, :with_image, weight: 0)] }

        it { is_expected.to be_valid }
      end
    end
  end
end
