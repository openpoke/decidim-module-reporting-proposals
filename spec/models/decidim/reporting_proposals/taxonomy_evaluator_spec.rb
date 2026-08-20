# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  describe TaxonomyEvaluator do
    subject { taxonomy_evaluator }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:evaluator_role) { create(:participatory_process_user_role, user:, participatory_process:, role: :evaluator) }
    let(:taxonomy_evaluator) { build(:taxonomy_evaluator) }

    it { is_expected.to be_valid }

    it "delegates user to the evaluator role" do
      expect(subject.user).to eq(subject.evaluator_role.user)
    end

    context "when taxonomy is a root taxonomy" do
      let(:taxonomy) { create(:taxonomy, organization:) }
      let(:taxonomy_evaluator) { build(:taxonomy_evaluator, taxonomy:, evaluator_role:) }

      it { is_expected.to be_valid }
    end

    context "when taxonomy belongs to a different organization" do
      let(:taxonomy) { create(:taxonomy, :with_parent) }
      let(:taxonomy_evaluator) { build(:taxonomy_evaluator, taxonomy:, evaluator_role:) }

      it { is_expected.not_to be_valid }
    end

    context "when the taxonomy is already assigned to the evaluator role" do
      let!(:existing_taxonomy_evaluator) { create(:taxonomy_evaluator) }
      let(:taxonomy_evaluator) { build(:taxonomy_evaluator, taxonomy: existing_taxonomy_evaluator.taxonomy, evaluator_role: existing_taxonomy_evaluator.evaluator_role) }

      it { is_expected.not_to be_valid }

      it "is enforced at the database level" do
        expect { taxonomy_evaluator.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    describe "participatory space user role overrides" do
      let!(:taxonomy_evaluator) { create(:taxonomy_evaluator) }
      let(:evaluator_role) { taxonomy_evaluator.evaluator_role }

      it "evaluator role returns taxonomy evaluators association" do
        expect(evaluator_role.taxonomy_evaluators).to include(taxonomy_evaluator)
      end

      it "destroys taxonomy evaluators when participatory_process_user_role is destroyed" do
        expect { evaluator_role.destroy }.to change(described_class, :count).by(-1)
      end

      it "does not destroy participatory_process_user_role on destroy" do
        expect { subject.destroy }.not_to(change(Decidim::ParticipatoryProcessUserRole, :count))
      end

      it "does not destroy taxonomy on destroy" do
        expect { subject.destroy }.not_to(change(Decidim::Taxonomy, :count))
      end
    end

    describe "evaluator role dependent records" do
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:assembly) { create(:assembly, organization:) }
      let(:assembly_role) { create(:assembly_user_role, user:, assembly:, role: :evaluator) }
      let(:component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:proposal) { create(:proposal, component:) }
      let!(:process_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }
      let!(:assembly_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: assembly_role) }
      let!(:process_assignment) { create(:evaluation_assignment, proposal:, evaluator_role:) }
      let!(:assembly_assignment) { create(:evaluation_assignment, proposal:, evaluator_role: assembly_role) }

      it "destroys taxonomy evaluators and evaluation assignments when the process role is destroyed" do
        expect { evaluator_role.destroy }.to change(described_class, :count).by(-1)
                                                                            .and change(Decidim::Proposals::EvaluationAssignment, :count).by(-1)
        expect { assembly_taxonomy_evaluator.reload }.not_to raise_error
        expect { assembly_assignment.reload }.not_to raise_error
      end

      it "destroys taxonomy evaluators and evaluation assignments when the assembly role is destroyed" do
        expect { assembly_role.destroy }.to change(described_class, :count).by(-1)
                                                                           .and change(Decidim::Proposals::EvaluationAssignment, :count).by(-1)
        expect { process_taxonomy_evaluator.reload }.not_to raise_error
        expect { process_assignment.reload }.not_to raise_error
      end
    end

    describe "cross-type isolation" do
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:) }
      let(:assembly) { create(:assembly, organization:) }
      let(:assembly_role) { create(:assembly_user_role, user:, assembly:, role: :evaluator) }
      let(:component) { create(:proposal_component, participatory_space: participatory_process) }
      let(:proposal) { create(:proposal, component:) }

      it "does not destroy records of another role type sharing the same id" do
        # polymorphic evaluator_role: same id, different type must not be affected
        assembly_role.update_column(:id, evaluator_role.id) # rubocop:disable Rails/SkipsModelValidations
        process_taxonomy_evaluator = create(:taxonomy_evaluator, taxonomy:, evaluator_role:)
        assembly_taxonomy_evaluator = create(:taxonomy_evaluator, taxonomy:, evaluator_role: assembly_role)
        process_assignment = create(:evaluation_assignment, proposal:, evaluator_role:)
        assembly_assignment = create(:evaluation_assignment, proposal:, evaluator_role: assembly_role)

        evaluator_role.destroy

        expect(described_class.where(id: process_taxonomy_evaluator.id)).not_to exist
        expect(Decidim::Proposals::EvaluationAssignment.where(id: process_assignment.id)).not_to exist
        expect { assembly_taxonomy_evaluator.reload }.not_to raise_error
        expect { assembly_assignment.reload }.not_to raise_error
      end
    end

    describe ".assignments_for" do
      subject { described_class.assignments_for([taxonomy], space_evaluator_roles) }

      let(:root_taxonomy) { create(:taxonomy, organization:) }
      let(:parent_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let(:taxonomy) { create(:taxonomy, parent: parent_taxonomy, organization:) }
      let(:space_evaluator_roles) { participatory_process.user_roles(:evaluator).for_space(participatory_process) }

      context "when the taxonomy has its own assignment" do
        let!(:own) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }
        let!(:inherited) { create(:taxonomy_evaluator, taxonomy: parent_taxonomy, evaluator_role: create(:participatory_process_user_role, user: create(:user, organization:), participatory_process:, role: :evaluator)) }

        it "returns the own assignment only (no merge with ancestors)" do
          expect(subject).to eq(taxonomy => [own])
        end
      end

      context "when only an ancestor has assignments" do
        let!(:root_assignment) { create(:taxonomy_evaluator, taxonomy: root_taxonomy, evaluator_role:) }

        it "resolves to the nearest ancestor with assignments" do
          expect(subject).to eq(taxonomy => [root_assignment])
        end
      end

      context "when no level of the chain has assignments" do
        it { is_expected.to eq(taxonomy => []) }
      end

      context "when the nearest level only has assignments of another space" do
        let(:other_process) { create(:participatory_process, organization:) }
        let(:other_space_role) { create(:participatory_process_user_role, user: create(:user, organization:), participatory_process: other_process, role: :evaluator) }
        let!(:other_space_assignment) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: other_space_role) }
        let!(:parent_assignment) { create(:taxonomy_evaluator, taxonomy: parent_taxonomy, evaluator_role:) }

        it "ignores it and resolves against the given roles only" do
          expect(subject).to eq(taxonomy => [parent_assignment])
        end
      end
    end
  end
end
