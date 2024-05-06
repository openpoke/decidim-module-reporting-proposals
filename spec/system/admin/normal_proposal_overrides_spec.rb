# frozen_string_literal: true

require "spec_helper"

describe "Send email to user with link" do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, component:) }
  let(:participatory_space) { component.participatory_space }
  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  include_context "when managing a component as an admin"

  before do
    within "tr", text: translated(proposal.title) do
      click_link_or_button "Answer proposal"
    end
  end

  it "shows the sending email link" do
    expect(page).to have_content("Send an email to user")
  end

  it "has a link to send email with author's email" do
    expect(page).to have_css("a[href*='mailto:#{proposal.creator_author.email}']")
  end

  context "when it is a proposal with geocoding data" do
    let!(:proposal) { create(:proposal, component:, address:, latitude:, longitude:) }

    it "does not show the address" do
      expect(page).to have_no_css(".address")
      expect(page).to have_no_css(".address__info")
      expect(page).to have_no_css(".address__map")
      expect(page).to have_no_content(address)
    end

    context "when component has geocoding enabled" do
      let!(:component) do
        create(:proposal_component,
               manifest:,
               participatory_space: participatory_process,
               settings: {
                 geocoding_enabled: true
               })
      end

      it "shows the address" do
        within ".admin-address" do
          expect(page).to have_content("Geolocated at")
          expect(page).to have_content(address)
        end
      end
    end
  end
end
