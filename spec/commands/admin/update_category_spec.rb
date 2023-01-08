# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe UpdateCategory do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }
    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let(:valuator_ids) { [valuator_role.id] }
    let(:form_params) do
      {
        "category" => {
          "name_en" => "New title",
          "description_en" => "Description",
          "valuator_ids" => valuator_ids
        }
      }
    end
    let(:form) do
      CategoryForm.from_params(
        form_params,
        current_participatory_space: participatory_space
      ).with_context(
        current_organization: organization
      )
    end

    let(:valuator_role) { create(:participatory_process_user_role, role: "valuator", user: user, participatory_process: participatory_space) }
    let(:category) { create(:category, participatory_space: participatory_space) }
    let(:command) { described_class.new(category, form) }

    it "adds the valuator roles" do
      command.call
      category.reload

      expect(category.valuator_users).to eq([valuator_role.user])
    end

    context "when removing valuator roles" do
      let(:valuator_ids) { [] }
      let!(:category_valuator) { create(:category_valuator, valuator_role: valuator_role, category: category) }

      it "removes the valuator roles" do
        expect(category.valuator_users).to eq([valuator_role.user])
        command.call
        category.reload

        expect(category.valuator_users).to be_empty
      end
    end
  end
end
