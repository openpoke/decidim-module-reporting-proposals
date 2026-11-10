# frozen_string_literal: true

require "spec_helper"
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

        it "returns the evaluators not assigned to the proposal" do
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
