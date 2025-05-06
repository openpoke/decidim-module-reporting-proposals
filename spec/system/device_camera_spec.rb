# frozen_string_literal: true

require "spec_helper"

describe "User camera button" do # rubocop:disable RSpec/DescribeClass
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) do
    create(:reporting_proposals_component,
           :with_extra_hashtags,
           participatory_space: participatory_process,
           settings: { only_photo_attachments: false })
  end
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let(:use_camera_button) { true }

  before do
    allow(Decidim::ReportingProposals).to receive(:use_camera_button).and_return(use_camera_button)
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "uses device camera" do
    it "has one camera button" do
      expect(page).to have_button("Use my camera", count: 1)
    end

    context "when option disabled" do
      let(:use_camera_button) { false }

      it "does not has the camera button" do
        expect(page).to have_no_button("Use my camera")
      end
    end
  end

  shared_examples "uses admin device camera" do
    it "has one camera button" do
      expect(page).to have_button("Use my camera", count: 1)
    end

    context "when option disabled" do
      let(:use_camera_button) { false }

      it "does not has the camera button" do
        expect(page).to have_no_button("Use my camera")
      end
    end
  end

  describe "#reporting_proposals" do
    before do
      visit_component
      click_on "New proposal"
      click_on "Add file"
    end

    it_behaves_like "uses device camera"
  end
end
