# frozen_string_literal: true

require "spec_helper"
require "decidim/admin/test/forms/category_form_examples"

module Decidim::Admin
  describe CategoryForm do
    include_examples "category form" do
      let(:participatory_space) do
        create :participatory_process, organization: organization
      end

      context "when valuators are assigned" do
        subject do
          described_class.from_model(
            category
          ).with_context(
            current_participatory_space: participatory_space,
            current_organization: organization
          )
        end

        let(:user) { create :user, organization: organization }
        let!(:category) { create :category, participatory_space: participatory_space }
        let!(:category_valuator) { create(:category_valuator, valuator_role: valuator_role, category: category) }
        let(:valuator_role) { create :participatory_process_user_role, role: "valuator", user: user, participatory_process: participatory_space }

        it "assigns the valuators" do
          expect(subject).to be_valid
          expect(subject.valuator_ids).to eq([valuator_role.id])
        end
      end
    end
  end
end
