# frozen_string_literal: true

require "spec_helper"

describe "Report and hide proposal" do
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }
  let!(:participatory_process) { create(:participatory_process, organization:) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, component: proposal_component) }
  let(:enabled) { true }
  let(:reportable) { create(:dummy_resource) }
  let(:moderation) { create(:moderation, reportable:, report_count: 1, participatory_space: participatory_process) }
  let!(:report) { create(:report, moderation:) }

  before do
    switch_to_host(organization.host)
    allow(Decidim::ReportingProposals.config).to receive(:allow_admins_to_hide_proposals).and_return(enabled)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link_or_button "Processes"

    within "#processes" do
      click_link_or_button translated(participatory_process.title)
    end

    click_link_or_button "Components"

    within "#components-list" do
      click_link_or_button "Proposals"
    end
  end

  it "admin can be report and hide the proposal" do
    expect(page).to have_css("button svg.icon--flag")

    expect(proposal).not_to be_hidden
    expect(proposal).not_to be_reported

    find("button svg.icon--flag").click
    click_link_or_button("button[type=submit]", text: "Report")

    expect(proposal.reload).not_to be_hidden
    expect(proposal).to be_reported

    expect(page).to have_css("a svg.icon--trash")

    find("a svg.icon--trash").click

    expect(page).to have_no_css("a svg.icon--trash")
    expect(page).to have_no_css("button svg.icon--flag")

    expect(proposal.reload).to be_hidden
    expect(proposal).to be_reported
  end

  context "when option is disabled" do
    let(:enabled) { false }
    let(:reportable) { proposal }

    it "dows not allow to report proposals but allows to hide it if reported" do
      expect(page).to have_no_css("a svg.icon--trash")
      expect(page).to have_no_css("button svg.icon--flag")
    end
  end
end
