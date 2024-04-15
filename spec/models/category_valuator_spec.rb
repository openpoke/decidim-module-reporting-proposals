# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  describe CategoryValuator do
    subject { category_valuator }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:category_valuator) { build(:category_valuator) }

    it { is_expected.to be_valid }

    context "when category belongs to a different participatory space" do
      let(:category) { create(:category, participatory_space: participatory_process) }
      let(:category_valuator) { build(:category_valuator, category:) }

      it { is_expected.not_to be_valid }
    end

    describe "category overrides" do
      let!(:category_valuator) { create(:category_valuator) }
      let(:category) { category_valuator.category }

      it "category returns valuator roles association" do
        expect(category.category_valuators).to include(category_valuator)
      end

      it "category returns valuator users" do
        expect(category.valuator_users).to include(category_valuator.user)
      end

      it "category returns valuator user names" do
        expect(category.valuator_names).to include(category_valuator.user.name)
      end

      it "destroys category valuators when category is destroyed" do
        expect(Decidim::ReportingProposals::CategoryValuator.count).to eq(1)
        expect { category.destroy }.to change(Decidim::ReportingProposals::CategoryValuator, :count).by(-1)
      end

      it "does not destroy category on destroy" do
        expect { subject.destroy }.not_to(change(Decidim::Category, :count))
      end
    end

    describe "participatory space user role overrides" do
      let!(:category_valuator) { create(:category_valuator) }
      let(:valuator_role) { category_valuator.valuator_role }

      it "destroys category valuators when participatory_process_user_role is destroyed" do
        expect(Decidim::ReportingProposals::CategoryValuator.count).to eq(1)
        expect { valuator_role.destroy }.to change(Decidim::ReportingProposals::CategoryValuator, :count).by(-1)
      end

      it "does not destroy participatory_process_user_role on destroy" do
        expect { subject.destroy }.not_to(change(Decidim::ParticipatoryProcessUserRole, :count))
      end

      # test to ensure valuationassignments are destroyed when valuator role is destroyed
      # we might have to remove this when https://github.com/decidim/decidim/issues/10353 is solved
      context "when participatory_process_user_role is a valuator" do
        let!(:valuation_assignment) { create(:valuation_assignment, proposal:) }
        let(:proposal) { create(:proposal, component:) }
        let(:component) { create(:proposal_component, participatory_space: participatory_process) }
        let(:valuator_role) { valuation_assignment.valuator_role }

        it "destroys valuation assignments when participatory_process_user_role is destroyed" do
          expect(Decidim::Proposals::ValuationAssignment.count).to eq(1)
          expect { valuator_role.destroy }.to change(Decidim::Proposals::ValuationAssignment, :count).by(-1)
        end
      end
    end
  end
end
