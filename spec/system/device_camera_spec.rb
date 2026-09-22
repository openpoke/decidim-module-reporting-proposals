# frozen_string_literal: true

require "spec_helper"

describe "User camera button" do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
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

    it "renders the button in the dropzone without a field wrapper" do
      expect(page).to have_css(".upload-modal__dropzone-container > .camera-container > button.user-device-camera")
      expect(page).to have_no_css(".upload-modal .input-group")
      expect(page).to have_no_css(".upload-modal .input-group-button")
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
      click_on "Add image or documents"
    end

    it_behaves_like "uses device camera"

    it "previews the uploaded image in the modal and in the form" do
      within ".upload-modal" do
        find("input[type='file']", visible: :all).attach_file(Decidim::Dev.asset("city.jpeg"))

        expect(page).to have_css("[data-filename='city.jpeg'] img[src^='data:image']", wait: 10)

        click_on "Save"
      end

      expect(page).to have_css(".upload-modal__files img[src^='data:image']", wait: 10)
    end
  end
end
