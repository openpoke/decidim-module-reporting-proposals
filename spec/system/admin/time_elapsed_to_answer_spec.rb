# frozen_string_literal: true

require "spec_helper"

describe "Time elapsed to answer", type: :system do
  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }

  let!(:reporting_proposals_component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:reporting_proposals) do
    [
      create(:proposal, :accepted, answered_at: 5.days.ago, component: reporting_proposals_component),
      create(:proposal, :rejected, created_at: 10.days.ago, published_at: 10.days.ago, answered_at: 5.days.ago, component: reporting_proposals_component)
    ]
  end
  let(:component) { reporting_proposals_component }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when proposal has accepted or rejected state " do
    before do
      visit manage_component_path(component)
    end

    it "proposal has time elapsed to answer" do
      expect(page).to have_content("Resolution time: 5 days", count: 2)
    end
  end
end
