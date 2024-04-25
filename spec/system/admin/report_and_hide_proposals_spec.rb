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

  def component_path
    Decidim::EngineRouter.admin_proxy(proposal_component).proposals_path(proposal_component.id)
  end

  before do
    switch_to_host(organization.host)
    allow(Decidim::ReportingProposals.config).to receive(:allow_admins_to_hide_proposals).and_return(enabled)
    login_as admin, scope: :user
    visit component_path
  end

  it "admin can be report and hide the proposal" do
    expect(page).to have_button("Report")

    expect(proposal).not_to be_hidden
    expect(proposal).not_to be_reported
    expect(page).to have_content(proposal.title["en"])

    click_link_or_button("Report")
    within ".modal__report" do
      click_link_or_button("Report")
    end

    expect(proposal.reload).not_to be_hidden
    expect(proposal).to be_reported
    expect(page).to have_content(proposal.title["en"])
    expect(page).to have_no_button("Report")
    expect(page).to have_link("Hide")

    click_link_or_button "Hide"

    expect(page).to have_no_link("Hide")
    expect(page).to have_no_button("Report")
    expect(page).to have_no_content(proposal.title["en"])
    expect(proposal.reload).to be_hidden
    expect(proposal).to be_reported
  end

  context "when option is disabled" do
    let(:enabled) { false }
    let(:reportable) { proposal }

    it "dows not allow to report proposals but allows to hide it if reported" do
      expect(page).to have_no_button("Report")
      expect(page).to have_no_link("Hide")
    end
  end
end
