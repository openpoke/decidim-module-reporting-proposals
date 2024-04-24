# frozen_string_literal: true

require "spec_helper"

describe "Add proposals photos" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }
  let!(:proposal) { create(:proposal, component:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit manage_component_path(component)
    page.find(".table__list-title a").click
  end

  context "when photos are added" do
    it "the photos are rendered in the photo section" do
      click_link_or_button "Photos"
      attach_file("proposal_photo_add_photos", Decidim::Dev.asset("city.jpeg"))
      click_link_or_button "Save images"
      click_link_or_button "Photos"

      expect(page).to have_css("img[src*=\"city.jpeg\"]", count: 1)

      attach_file("proposal_photo_add_photos", Decidim::Dev.asset("city.jpeg"))
      click_link_or_button "Save images"

      click_link_or_button "Photos"
      expect(page).to have_css("img[src*=\"city.jpeg\"]", count: 2)

      expect(page).to have_css(".delete-proposal__button", count: 2)
    end
  end
end
