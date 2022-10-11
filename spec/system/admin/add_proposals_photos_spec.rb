# frozen_string_literal: true

require "spec_helper"

describe "Add proposals photos", type: :system do
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:component) { create :reporting_proposals_component, participatory_space: participatory_process }
  let!(:user) { create(:user, :confirmed, :admin, organization: organization) }
  let!(:proposal) { create(:proposal, component: component) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit manage_component_path(component)
    page.find(".table__list-title a").click
  end

  it "has 'Photos' section" do
    expect(page).to have_content("Add image")
  end

  context "when photos are added" do
    it "the photos are rendered in the photo section" do
      attach_file("proposal_photo_add_photos", Decidim::Dev.asset("city.jpeg"))
      click_button "Add image"

      expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 1)

      attach_file("proposal_photo_add_photos", Decidim::Dev.asset("city.jpeg"))
      click_button "Add image"

      expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 2)

      expect(page).to have_css(".delete-proposal__button", count: 2)
    end
  end
end
