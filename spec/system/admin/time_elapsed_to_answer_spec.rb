# frozen_string_literal: true

require "spec_helper"

describe "Time elapsed to answer" do
  let(:admin) { create(:user, :admin, :confirmed) }
  let(:organization) { admin.organization }
  let!(:participatory_process) { create(:participatory_process, organization:) }

  let!(:reporting_proposals_component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:reporting_proposal) do
    create(:proposal, state:, state_published_at: 10.days.ago, answered_at:, component: reporting_proposals_component)
  end
  let(:component) { reporting_proposals_component }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit manage_component_path(component)
  end

  context "when proposal is rejected" do
    let(:state) { "rejected" }
    let(:answered_at) { 5.days.ago }

    it "proposal has time elapsed to answer" do
      expect(page).to have_content("Resolution time: 5 days", count: 1)
    end
  end

  context "when proposal is accepted" do
    let(:state) { "accepted" }
    let(:answered_at) { 5.days.ago }

    it "proposal has time elapsed to answer" do
      expect(page).to have_content("Resolution time: 5 days", count: 1)
    end
  end

  context "when proposal is not_answered" do
    let(:state) { "not_answered" }
    let(:answered_at) { nil }

    it "proposal has time elapsed to answer" do
      expect(page).not_to have_content("Resolution time:")
    end
  end
end
