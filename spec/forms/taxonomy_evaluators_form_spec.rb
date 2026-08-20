# frozen_string_literal: true

require "spec_helper"
require "decidim/assemblies/test/factories"

module Decidim::ReportingProposals
  describe Admin::TaxonomyEvaluatorsForm do
    subject { described_class.from_params(attributes).with_context(context) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:context) { { current_organization: organization, current_participatory_space: participatory_process } }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
    let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, participatory_process:, user: create(:user, organization:)) }
    let(:another_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, participatory_process:, user: create(:user, organization:)) }
    let(:taxonomy_id) { taxonomy.id }
    let(:evaluator_role_ids) { [evaluator_role.id, another_evaluator_role.id] }
    let(:attributes) { { taxonomy_id:, evaluator_role_ids: } }

    it { is_expected.to be_valid }

    it "returns the evaluator roles" do
      expect(subject.evaluator_roles).to contain_exactly(evaluator_role, another_evaluator_role)
    end

    it "returns the taxonomy" do
      expect(subject.taxonomy).to eq(taxonomy)
    end

    context "when no evaluator roles are selected" do
      let(:evaluator_role_ids) { [] }

      it { is_expected.to be_valid }
    end

    context "when evaluator role ids contain blank strings" do
      let(:evaluator_role_ids) { ["", evaluator_role.id.to_s, ""] }

      it { is_expected.to be_valid }

      it "ignores the blank values" do
        expect(subject.evaluator_role_ids).to eq([evaluator_role.id])
      end
    end

    context "when evaluator role ids contain duplicates" do
      let(:evaluator_role_ids) { [evaluator_role.id, evaluator_role.id] }

      it { is_expected.to be_valid }

      it "returns the evaluator role once" do
        expect(subject.evaluator_roles).to contain_exactly(evaluator_role)
      end
    end

    context "when the taxonomy is missing" do
      let(:taxonomy_id) { nil }

      it { is_expected.not_to be_valid }
    end

    context "when the taxonomy is a root taxonomy" do
      let(:taxonomy_id) { root_taxonomy.id }

      it { is_expected.to be_valid }
    end

    context "when the taxonomy belongs to another organization" do
      let(:taxonomy_id) { create(:taxonomy, :with_parent).id }

      it { is_expected.not_to be_valid }
    end

    context "when an evaluator role belongs to another participatory space" do
      let(:other_process_role) { create(:participatory_process_user_role, role: :evaluator, participatory_process: create(:participatory_process, organization:), user: create(:user, organization:)) }
      let(:evaluator_role_ids) { [evaluator_role.id, other_process_role.id] }

      it { is_expected.not_to be_valid }
    end

    context "when a role is not an evaluator role" do
      let(:admin_role) { create(:participatory_process_user_role, role: :admin, participatory_process:, user: create(:user, organization:)) }
      let(:evaluator_role_ids) { [admin_role.id] }

      it { is_expected.not_to be_valid }
    end

    context "when a conflicting taxonomy_id comes in the nested params" do
      subject { described_class.from_params(nested_attributes).with_context(context) }

      let(:other_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
      let(:nested_attributes) { { taxonomy_id: taxonomy.id, taxonomy_evaluators: { taxonomy_id: other_taxonomy.id, evaluator_role_ids: } } }

      it "lets the nested param win over the top-level one" do
        expect(subject.taxonomy_id).to eq(other_taxonomy.id)
      end

      it "enforces the taxonomy assigned through the attribute writer" do
        subject.taxonomy_id = taxonomy.id

        expect(subject.taxonomy).to eq(taxonomy)
        expect(subject).to be_valid
      end
    end

    context "when the participatory space is a child assembly" do
      let(:parent_assembly) { create(:assembly, organization:) }
      let(:child_assembly) { create(:assembly, parent: parent_assembly, organization:) }
      let(:context) { { current_organization: organization, current_participatory_space: child_assembly } }
      let(:child_evaluator_role) { create(:assembly_user_role, role: :evaluator, assembly: child_assembly, user: create(:user, organization:)) }
      let(:parent_evaluator_role) { create(:assembly_user_role, role: :evaluator, assembly: parent_assembly, user: create(:user, organization:)) }

      context "with an evaluator role of the assembly itself" do
        let(:evaluator_role_ids) { [child_evaluator_role.id] }

        it { is_expected.to be_valid }
      end

      context "with an evaluator role of the parent assembly" do
        let(:evaluator_role_ids) { [parent_evaluator_role.id] }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
