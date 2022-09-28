# frozen_string_literal: true

require "spec_helper"

describe "Report and hide proposal", type: :system do
  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:proposal) { create :proposal, component: proposal_component }

  before do
    switch_to_host(organization.host)
    allow(Decidim::ReportingProposals.config).to receive(:allow_admins_to_hide_proposals).and_return(true)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Processes"

    within "#processes" do
      click_link translated(participatory_process.title)
    end

    click_link "Components"

    within "#components-list" do
      click_link "Proposals"
    end
  end

  context "when the proposal has not been reported" do
    it "admin can be report and hide the proposal" do
      expect(page).to have_css("button svg.icon--flag")

      find("button svg.icon--flag").click
      find("button[type=submit]", text: "Report").click

      expect(page).to have_css("a svg.icon--trash")

      find("a svg.icon--trash").click

      expect(page).not_to have_css("a svg.icon--trash")
      expect(page).not_to have_css("button svg.icon--flag")
    end
  end
end
