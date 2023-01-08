# frozen_string_literal: true

require "spec_helper"

module Decidim::Admin
  describe CreateCategory do
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
    let(:command) { described_class.new(form, participatory_space) }
    let(:category) { Decidim::Category.last }

    it "adds the valuator roles" do
      command.call
      expect(category.valuator_users).to eq([valuator_role.user])
    end
  end
end
