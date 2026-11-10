# frozen_string_literal: true

require "spec_helper"
require "decidim/initiatives/test/factories"

module Decidim::Proposals::Admin
  describe ProposalBulkActionsHelper do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }

    describe "#find_evaluators_for_select" do
      context "when the space is a participatory process" do
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:evaluator) { create(:user, :confirmed, organization:) }
        let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }

        it "returns the evaluators of the space" do
          expect(helper.find_evaluators_for_select(participatory_process, user)).to eq([[evaluator.name, evaluator_role.id]])
        end
      end

      context "when the space has no user roles" do
        let(:initiative) { create(:initiative, organization:) }

        it "returns no evaluators" do
          expect(helper.find_evaluators_for_select(initiative, user)).to eq([])
        end
      end
    end
  end
end
