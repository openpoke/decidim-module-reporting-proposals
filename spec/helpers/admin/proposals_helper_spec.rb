# frozen_string_literal: true

require "spec_helper"
require "decidim/assemblies/test/factories"
require "decidim/initiatives/test/factories"

module Decidim::Proposals::Admin
  describe ProposalsHelper do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:component) { create(:proposal_component, participatory_space:) }
    let(:proposal) { create(:proposal, component:) }

    describe "#available_evaluators_for_proposal" do
      context "when the space is a participatory process" do
        let(:participatory_space) { create(:participatory_process, organization:) }
        let(:evaluator) { create(:user, :confirmed, organization:) }
        let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process: participatory_space) }

        it "returns the evaluators of the space" do
          expect(helper.available_evaluators_for_proposal(proposal, user)).to eq([[evaluator.name, evaluator_role.id]])
        end

        context "and an evaluator is already assigned to the proposal" do
          let(:assigned_evaluator) { create(:user, :confirmed, organization:) }
          let(:assigned_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: assigned_evaluator, participatory_process: participatory_space) }
          let!(:evaluation_assignment) { create(:evaluation_assignment, proposal:, evaluator_role: assigned_evaluator_role) }

          it "does not return the assigned evaluator" do
            expect(helper.available_evaluators_for_proposal(proposal, user)).to eq([[evaluator.name, evaluator_role.id]])
          end
        end

        context "and the current user is one of the evaluators" do
          it "does not return the current user" do
            expect(helper.available_evaluators_for_proposal(proposal, evaluator)).to eq([])
          end
        end
      end

      context "when the space is a child assembly" do
        let(:parent_assembly) { create(:assembly, organization:) }
        let(:participatory_space) { create(:assembly, parent: parent_assembly, organization:) }
        let(:evaluator) { create(:user, :confirmed, organization:) }
        let(:parent_evaluator) { create(:user, :confirmed, organization:) }
        let!(:evaluator_role) { create(:assembly_user_role, role: :evaluator, user: evaluator, assembly: participatory_space) }
        let!(:parent_evaluator_role) { create(:assembly_user_role, role: :evaluator, user: parent_evaluator, assembly: parent_assembly) }

        it "does not return the evaluators of the parent assembly" do
          expect(helper.available_evaluators_for_proposal(proposal, user)).to eq([[evaluator.name, evaluator_role.id]])
        end
      end

      context "when the space has no user roles" do
        let(:participatory_space) { create(:initiative, organization:) }

        it "returns no evaluators" do
          expect(helper.available_evaluators_for_proposal(proposal, user)).to eq([])
        end
      end
    end
  end
end
