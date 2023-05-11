# frozen_string_literal: true

require "spec_helper"
require "decidim/budgets/test/factories"

module Decidim::Budgets
  describe Admin::ProjectForm do
    subject { described_class.from_model(project).with_context(context) }

    let(:organization) { create(:organization, available_locales: [:en]) }
    let(:context) do
      {
        current_organization: organization,
        current_component: current_component,
        current_participatory_space: participatory_process
      }
    end
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:current_component) { create :budgets_component, participatory_space: participatory_process }
    let(:budget) { create :budget, component: current_component }
    let(:proposals_component) { create :component, manifest_name: :proposals, participatory_space: participatory_process }
    let(:proposals) { create_list :proposal, 2, component: proposals_component }
    let(:reporting_component) { create :component, manifest_name: :reporting_proposals, participatory_space: participatory_process }
    let(:reporting_proposals) { create_list :proposal, 2, component: reporting_component }
    let(:parent_scope) { create(:scope, organization: organization) }
    let(:scope) { create(:subscope, parent: parent_scope) }
    let(:category) { create :category, participatory_space: participatory_process }
    let(:project) do
      create(
        :project,
        budget: budget,
        scope: scope,
        category: category
      )
    end

    before do
      project.link_resources(proposals + reporting_proposals, "included_proposals")
    end

    describe "#map_model" do
      it "sets the proposal_ids correctly" do
        expect(subject.proposal_ids).to match_array(proposals.map(&:id) + reporting_proposals.map(&:id))
      end
    end

    describe "#proposals" do
      it "returns the available proposals in a way suitable for the form" do
        expect(subject.proposals).to match_array(proposals + reporting_proposals)
      end
    end
  end
end
