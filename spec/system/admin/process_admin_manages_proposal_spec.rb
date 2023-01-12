# frozen_string_literal: true

require "spec_helper"

describe "Process admin manages proposals", type: :system do
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:component) { create :reporting_proposals_component, participatory_space: participatory_process }
  let!(:proposal) { create :proposal, component: component }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let!(:user_role) { create(:participatory_process_user_role, role: :admin, user: user, participatory_process: participatory_process) }

  def edit_component_path(component)
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit manage_component_path(component)
  end

  context "when the process admin reports" do
    it "has a flag report " do
      expect(page).to have_css("button.link-alt", count: 1)
    end
  end

  context "when the process admin add a photo" do
    before do
      click_link proposal.title["en"]
    end

    it "can add and delete images" do
      click_button "Add image"
      attach_file("proposal_photo_add_photos", Decidim::Dev.asset("city.jpeg"))
      click_button "Add image"

      expect(page).to have_selector("img[src*=\"city.jpeg\"]", count: 1)
      expect(page).to have_css(".delete-proposal__button", count: 1)
    end
  end
end
