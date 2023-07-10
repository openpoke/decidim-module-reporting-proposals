# frozen_string_literal: true

require "spec_helper"

describe "User location button", type: :system do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) do
    create(:reporting_proposals_component,
           :with_extra_hashtags,
           participatory_space: participatory_process)
  end
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let(:address) { "Plaça Santa Jaume, 1, 08002 Barcelona" }
  let(:latitude) { 41.3825 }
  let(:longitude) { 2.1772 }
  let(:all_manifests) { [:proposals, :meetings, :reporting_proposals] }
  let(:manifests) { all_manifests }

  before do
    stub_geocoding(address, [latitude, longitude])
    allow(Decidim::ReportingProposals).to receive(:show_my_location_button).and_return(manifests)
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "uses device location" do
    it "has my location button" do
      expect(page).to have_button("Use my location")
    end

    context "when option disabled" do
      let(:manifests) { all_manifests - [component.manifest_name.to_sym] }

      it "does not has the location button" do
        expect(page).not_to have_button("Use my location")
      end
    end
  end

  shared_examples "has no address" do
    context "when has_no_address is checked" do
      before do
        find("#proposal_has_no_address").click
      end

      it "the button should be deactivated and the errors removed" do
        expect(page).to have_css(".user-device-location button[disabled]")
        expect(page).not_to have_css("label[for=proposal_address].is-invalid-label")
        expect(page).to have_css("input#proposal_address[disabled]")
      end
    end
  end

  describe "#reporting_proposals", :serves_geocoding_autocomplete do
    before do
      visit_component
      click_link "New proposal"
    end

    it_behaves_like "uses device location"
    it_behaves_like "has no address"
  end

  context "when admin", :serves_geocoding_autocomplete do
    before do
      visit manage_component_path(component)
      click_link "New proposal"
    end

    it_behaves_like "uses device location"
  end

  describe "#proposals", :serves_geocoding_autocomplete do
    let(:manifest_name) { "proposals" }
    let!(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_geocoding_enabled,
             participatory_space: participatory_process)
    end
    let(:proposal) { create(:proposal, :draft, component: component, users: [user]) }

    before do
      visit_component
      visit "#{Decidim::EngineRouter.main_proxy(component).proposal_path(proposal)}/complete"
      check "proposal_has_address"
    end

    it_behaves_like "uses device location"

    context "when admin", :serves_geocoding_autocomplete do
      before do
        visit manage_component_path(component)
        click_link "New proposal"
      end

      it_behaves_like "uses device location"
    end
  end

  describe "#meetings", :serves_geocoding_autocomplete do
    let(:manifest_name) { "meetings" }
    let!(:component) do
      create(:meeting_component,
             :with_creation_enabled,
             participatory_space: participatory_process)
    end

    before do
      visit_component
      click_link "New meeting"
      select "In person", from: :meeting_type_of_meeting
    end

    it_behaves_like "uses device location"

    context "when admin", :serves_geocoding_autocomplete do
      before do
        visit manage_component_path(component)
        click_link "New meeting"
        select "In person", from: :meeting_type_of_meeting
      end

      it_behaves_like "uses device location"
    end
  end
end
