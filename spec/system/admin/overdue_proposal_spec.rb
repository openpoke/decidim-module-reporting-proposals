# frozen_string_literal: true

require "spec_helper"
require "system/shared/admin_proposals_overdue_examples"

describe "Highlighted proposal", type: :system do
  let(:admin) { create :user, :admin, :confirmed }
  let(:organization) { admin.organization }
  let!(:participatory_process) { create(:participatory_process, organization: organization) }
  let!(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:proposals) do
    [
      create(:proposal, :not_answered, created_at: 10.days.ago, published_at: 10.days.ago, component:
        proposal_component),
      create(:proposal, :evaluating, created_at: 10.days.ago, published_at: 10.days.ago, answered_at: 5.days.ago, component:
        proposal_component),
      create(:proposal, :accepted, created_at: 10.days.ago, published_at: 10.days.ago, component:
        proposal_component)
    ]
  end
  let!(:reporting_proposals_component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:reporting_proposals) do
    [
      create(:proposal, :not_answered, created_at: 10.days.ago, published_at: 10.days.ago, component:
        reporting_proposals_component),
      create(:proposal, :evaluating, created_at: 10.days.ago, published_at: 10.days.ago, answered_at: 5.days.ago, component:
        reporting_proposals_component),
      create(:proposal, :accepted, created_at: 10.days.ago, published_at: 10.days.ago, component:
        reporting_proposals_component)
    ]
  end

  before do
    allow(Decidim::ReportingProposals).to receive(:unanswered_proposals_overdue).and_return unanswered_days_overdue.to_i
    allow(Decidim::ReportingProposals).to receive(:evaluating_proposals_overdue).and_return evaluating_days_overdue.to_i
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when managing standard proposals" do
    before do
      visit manage_component_path(proposal_component)
    end

    it_behaves_like "proposals list has no due dates"
    it_behaves_like "proposals list has overdue dates"
  end

  context "when managing reporting proposals" do
    before do
      visit manage_component_path(reporting_proposals_component)
    end

    it_behaves_like "proposals list has no due dates"
    it_behaves_like "proposals list has overdue dates"
  end
end
