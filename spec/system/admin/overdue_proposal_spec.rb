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
  let(:unanswered_days_overdue) { 7 }
  let(:evaluating_days_overdue) { 3 }
  let(:component) { proposal_component }

  def edit_component_path(component)
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
  end

  context "when configuring the module" do
    before do
      visit edit_component_path(component)
    end

    context "when managing standard proposals" do
      it_behaves_like "has overdue settings"
    end

    context "when managing reporting proposals" do
      let(:component) { reporting_proposals_component }

      it_behaves_like "has overdue settings"
    end
  end

  context "when managing the module" do
    before do
      component.update!(settings: { unanswered_proposals_overdue: unanswered_days_overdue, evaluating_proposals_overdue: evaluating_days_overdue })
      visit manage_component_path(component)
    end

    context "when managing standard proposals" do
      it_behaves_like "proposals list has no due dates"
      it_behaves_like "proposals list has overdue dates"
    end

    context "when managing reporting proposals" do
      let(:component) { reporting_proposals_component }

      it_behaves_like "proposals list has no due dates"
      it_behaves_like "proposals list has overdue dates"
    end
  end
end
