# frozen_string_literal: true

require "spec_helper"

describe "User camera button", type: :system do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) do
    create(:reporting_proposals_component,
           :with_extra_hashtags,
           participatory_space: participatory_process,
           settings: { only_photo_attachments: false })
  end
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let(:all_manifests) { [:proposals, :reporting_proposals] }
  let(:manifests) { all_manifests }

  before do
    allow(Decidim::ReportingProposals).to receive(:use_camera_button).and_return(manifests)
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "uses device camera" do
    it "has one camera button" do
      expect(page).to have_button("Use my camera", count: 1)
    end

    context "when option disabled" do
      let(:manifests) { all_manifests - [component.manifest_name.to_sym] }

      it "does not has the camera button" do
        expect(page).not_to have_button("Use my camera")
      end
    end
  end

  shared_examples "uses admin device camera" do
    it "has one camera button" do
      expect(page).to have_button("Use my camera", count: 1)
    end

    context "when option disabled" do
      let(:manifests) { all_manifests - [component.manifest_name.to_sym] }

      it "does not has the camera button" do
        expect(page).not_to have_button("Use my camera")
      end
    end
  end

  describe "#reporting_proposals" do
    before do
      visit_component
      click_link "New proposal"
    end

    it_behaves_like "uses device camera"
  end

  # version .27 uses a modal to upload files, we are not touching it (for the moment)
  # In case we want to add the "use my camera" button in the admin, this should be reactivated
  # context "when admin" do
  #   before do
  #     visit manage_component_path(component)
  #     click_link "New proposal"
  #   end

  #   it_behaves_like "uses admin device camera"
  # end

  describe "#proposals" do
    let(:manifest_name) { "proposals" }
    let!(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_attachments_allowed,
             participatory_space: participatory_process)
    end
    let(:proposal) { create(:proposal, :draft, component: component, users: [user]) }

    before do
      visit_component
      visit "#{Decidim::EngineRouter.main_proxy(component).proposal_path(proposal)}/complete"
    end

    it_behaves_like "uses device camera"

    # context "when admin" do
    #   before do
    #     visit manage_component_path(component)
    #     click_link "New proposal"
    #   end

    #   it_behaves_like "uses admin device camera"
    # end
  end
end
