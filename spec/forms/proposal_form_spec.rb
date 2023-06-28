# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ReportingProposals
    describe ProposalForm do
      subject { described_class.from_params(params).with_context(context) }

      let(:organization) { create(:organization, available_locales: [:en]) }
      let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
      let(:component) { create(:reporting_proposals_component, participatory_space: participatory_space) }
      let(:title) { "More sidewalks and less roads!" }
      let(:body) { "Everything would be better" }
      let(:author) { create(:user, organization: organization) }
      let(:user_group) { create(:user_group, :verified, users: [author], organization: organization) }
      let(:user_group_id) { user_group.id }
      let(:category) { create(:category, participatory_space: participatory_space) }
      let(:parent_scope) { create(:scope, organization: organization) }
      let(:scope) { create(:subscope, parent: parent_scope) }
      let(:category_id) { category.try(:id) }
      let(:scope_id) { scope.try(:id) }
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let(:has_no_address) { false }
      let(:has_no_image) { false }
      let(:address) { "Some address" }
      let(:image) { [Decidim::Dev.test_file("city.jpeg", "image/jpeg")] }
      let(:suggested_hashtags) { [] }
      let(:attachment_params) { nil }
      let(:meeting_as_author) { false }
      let(:params) do
        {
          title: title,
          body: body,
          author: author,
          category_id: category_id,
          scope_id: scope_id,
          address: address,
          latitude: latitude,
          longitude: longitude,
          has_no_address: has_no_address,
          has_no_image: has_no_image,
          add_photos: image,
          meeting_as_author: meeting_as_author,
          attachment: attachment_params,
          suggested_hashtags: suggested_hashtags
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
          expect(subject.category_id).to eq(category_id)
          expect(subject.address).to eq(address)
          expect(subject.latitude).to eq(latitude)
          expect(subject.longitude).to eq(longitude)
        end
      end

      context "when there's no address" do
        let(:address) { nil }

        it { is_expected.to be_invalid }

        context "and address is not required" do
          let(:has_no_address) { true }

          it { is_expected.to be_valid }
        end
      end

      context "when there's no image" do
        let(:image) { nil }

        it { is_expected.to be_invalid }

        context "and image is not required" do
          let(:has_no_image) { true }

          it { is_expected.to be_valid }
        end
      end

      context "when editing an existing proposal" do
        subject { described_class.from_model(proposal).with_context(context) }

        let!(:proposal) { create(:proposal, attachments: attachments, component: component) }
        let(:attachments) { [create(:attachment, :with_image, weight: 0)] }

        it { is_expected.to be_valid }
      end
    end
  end
end
