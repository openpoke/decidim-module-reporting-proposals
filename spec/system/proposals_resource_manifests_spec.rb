# frozen_string_literal: true

require "spec_helper"
require "decidim/accountability/test/factories"
require "decidim/meetings/test/factories"
require "decidim/budgets/test/factories"
require "decidim/elections/test/factories"
require "decidim/proposals/test/capybara_proposals_picker"

describe "Admin find_resource_manifest", type: :system do
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:reporting_component) { create :reporting_proposals_component, participatory_space: participatory_process }
  let(:proposal_component) { create :proposal_component, participatory_space: participatory_process }
  let(:accountability_component) { create :accountability_component, participatory_space: participatory_process }
  let(:budget_component) { create :accountability_component, participatory_space: participatory_process }
  let(:user) { create(:user, :confirmed, :admin, organization: organization) }
  let!(:reporting_proposal) { create(:proposal, title: { en: "reporting_proposal" }, component: reporting_component) }
  let!(:proposal) { create(:proposal, title: { en: "proposal" }, component: proposal_component) }
  let!(:result) { create(:result, component: accountability_component) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "admin can use reporting proposals in accountability" do
    visit manage_component_path(accountability_component)

    click_link "Edit"

    within ".edit_result" do
      proposals_pick(select_data_picker(:result_proposals, multiple: true), [proposal, reporting_proposal])
      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")
    click_link "Edit"
    expect(page).to have_content(translated(proposal.title))
    expect(page).to have_content(translated(reporting_proposal.title))
  end

  # TODO: meetings, budgets, elections
end
