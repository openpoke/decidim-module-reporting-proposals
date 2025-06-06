# frozen_string_literal: true

require "spec_helper"

describe "Add proposals photos" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:reporting_component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let(:component) { reporting_component }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }
  let!(:proposal) { create(:proposal, component:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    proposal_component.update!(
      settings: { attachments_allowed: true, proposal_photo_editing_enabled: true }
    )

    visit manage_component_path(component)
    page.find(".table__list-title a").click
  end

  shared_examples "can add photos" do
    it "has a photo section" do
      click_on "Photos"
      dynamically_attach_file("proposal_photo_add_photos", Decidim::Dev.asset("city.jpeg"))
      click_on "Save images"
      click_on "Photos"

      expect(page).to have_css("img[src*=\"city.jpeg\"]", count: 1)

      dynamically_attach_file("proposal_photo_add_photos", Decidim::Dev.asset("city.jpeg"))
      click_on "Save images"

      click_on "Photos"
      expect(page).to have_css("img[src*=\"city.jpeg\"]", count: 2)

      expect(page).to have_css(".delete-proposal__button", count: 2)
    end
  end

  it_behaves_like "can add photos"

  context "when normal proposals component" do
    let(:component) { proposal_component }

    it_behaves_like "can add photos"
  end
end
