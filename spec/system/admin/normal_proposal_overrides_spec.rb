# frozen_string_literal: true

require "spec_helper"

describe "Send email to user with link", type: :system do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, component: component) }
  let(:participatory_space) { component.participatory_space }
  let(:address) { "Some address" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  include_context "when managing a component as an admin"

  before do
    within find("tr", text: translated(proposal.title)) do
      click_link "Answer proposal"
    end
  end

  it "shows the sending email link" do
    expect(page).to have_content("Send an email to user")
  end

  it "has a link to send email with author's email" do
    expect(page).to have_selector("a[href*='mailto:#{proposal.creator_author.email}']")
  end

  context "when it is a proposal with geocoding data" do
    let!(:proposal) { create(:proposal, component: component, address: address, latitude: latitude, longitude: longitude) }

    it "does not show the address" do
      expect(page).not_to have_css(".address")
      expect(page).not_to have_css(".address__info")
      expect(page).not_to have_css(".address__map")
      expect(page).not_to have_content(address)
    end

    context "when component has geocoding enabled" do
      let!(:component) do
        create(:proposal_component,
               manifest: manifest,
               participatory_space: participatory_process,
               settings: {
                 geocoding_enabled: true
               })
      end

      it "shows the address" do
        within ".address__info" do
          expect(page).to have_css(".address__details")
          expect(page).to have_content(address)
        end
      end
    end
  end
end
