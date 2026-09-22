# frozen_string_literal: true

require "spec_helper"
require "decidim/assemblies/test/factories"

module Decidim::ReportingProposals
  describe Admin::UpdateTaxonomyEvaluators do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :confirmed, :admin, organization:) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
    let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, participatory_process:, user: create(:user, organization:)) }
    let(:another_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, participatory_process:, user: create(:user, organization:)) }
    let(:evaluator_role_ids) { [evaluator_role.id, another_evaluator_role.id] }
    let(:context) { { current_organization: organization, current_participatory_space: participatory_process, current_user: } }
    let(:form) { Admin::TaxonomyEvaluatorsForm.from_params(taxonomy_id: taxonomy.id, evaluator_role_ids:).with_context(context) }

    context "when the form is valid" do
      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "creates the taxonomy evaluators" do
        expect { subject.call }.to change(TaxonomyEvaluator, :count).by(2)

        expect(TaxonomyEvaluator.where(taxonomy:).map(&:evaluator_role)).to contain_exactly(evaluator_role, another_evaluator_role)
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:create!)
          .with(TaxonomyEvaluator, current_user, { taxonomy:, evaluator_role: kind_of(Decidim::ParticipatoryProcessUserRole) }, hash_including(:evaluator_user_name))
          .twice
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count).by(2)
        expect(Decidim::ActionLog.last.version.event).to eq "create"
        expect(Decidim::ActionLog.last.extra["evaluator_user_name"]).to be_present
      end

      context "when an evaluator is already assigned" do
        let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }

        it "creates only the missing taxonomy evaluators" do
          expect { subject.call }.to change(TaxonomyEvaluator, :count).by(1)

          expect(taxonomy_evaluator.reload).to be_persisted
        end
      end

      context "when an evaluator is removed" do
        let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: another_evaluator_role) }
        let(:evaluator_role_ids) { [evaluator_role.id] }

        it "destroys the removed taxonomy evaluators and creates the added ones" do
          expect { subject.call }.not_to change(TaxonomyEvaluator, :count)

          expect(TaxonomyEvaluator.where(taxonomy:).map(&:evaluator_role)).to contain_exactly(evaluator_role)
        end

        it "traces the removal", versioning: true do
          expect { subject.call }.to change(Decidim::ActionLog.where(action: "delete"), :count).by(1)

          action_log = Decidim::ActionLog.where(action: "delete").last
          expect(action_log.extra["taxonomy_name"]).to eq(taxonomy.name)
          expect(action_log.extra["evaluator_user_name"]).to eq(another_evaluator_role.user.name)
          expect(action_log.version.event).to eq "destroy"
        end
      end

      context "when all evaluators are removed" do
        let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }
        let(:evaluator_role_ids) { [] }

        it "destroys all the taxonomy evaluators" do
          expect { subject.call }.to change(TaxonomyEvaluator, :count).by(-1)
        end
      end

      context "when the taxonomy is mapped to a role from another participatory space" do
        let(:other_process_role) { create(:participatory_process_user_role, role: :evaluator, participatory_process: create(:participatory_process, organization:), user: create(:user, organization:)) }
        let!(:other_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: other_process_role) }
        let(:evaluator_role_ids) { [] }

        it "does not touch the mappings of other participatory spaces" do
          expect { subject.call }.not_to change(TaxonomyEvaluator, :count)

          expect(other_taxonomy_evaluator.reload).to be_persisted
        end
      end

      context "when the taxonomy is mapped to a role from a parent assembly" do
        let(:parent_assembly) { create(:assembly, organization:) }
        let(:child_assembly) { create(:assembly, parent: parent_assembly, organization:) }
        let(:context) { { current_organization: organization, current_participatory_space: child_assembly, current_user: } }
        let(:parent_evaluator_role) { create(:assembly_user_role, role: :evaluator, assembly: parent_assembly, user: create(:user, organization:)) }
        let!(:parent_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: parent_evaluator_role) }
        let(:evaluator_role_ids) { [] }

        it "does not touch the mappings of the parent assembly" do
          expect { subject.call }.not_to change(TaxonomyEvaluator, :count)

          expect(parent_taxonomy_evaluator.reload).to be_persisted
        end
      end

      context "when another admin creates the same mapping concurrently" do
        let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: another_evaluator_role) }
        let(:evaluator_role_ids) { [evaluator_role.id] }

        before { allow(Decidim.traceability).to receive(:create!).and_raise(ActiveRecord::RecordNotUnique) }

        it "broadcasts invalid and rolls back the removals" do
          expect { subject.call }.to broadcast(:invalid)

          expect(TaxonomyEvaluator.count).to eq(1)
          expect(taxonomy_evaluator.reload).to be_persisted
        end
      end
    end

    context "when the form is not valid" do
      context "when the taxonomy is missing" do
        let(:form) { Admin::TaxonomyEvaluatorsForm.from_params(taxonomy_id: nil, evaluator_role_ids:).with_context(context) }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when an evaluator role belongs to another participatory space" do
        let(:other_process_role) { create(:participatory_process_user_role, role: :evaluator, participatory_process: create(:participatory_process, organization:), user: create(:user, organization:)) }
        let(:evaluator_role_ids) { [other_process_role.id] }

        it "broadcasts invalid and does not create any taxonomy evaluator" do
          expect { subject.call }.to broadcast(:invalid)
          expect(TaxonomyEvaluator.count).to be_zero
        end
      end
    end
  end
end
