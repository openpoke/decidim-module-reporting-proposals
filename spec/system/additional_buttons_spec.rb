# frozen_string_literal: true

require "spec_helper"

describe "Additional button", type: :system do
  include_context "with a component"

  let(:manifest_name) { "reporting_proposals" }
  let!(:participatory_process) { create :participatory_process, :published }
  let!(:organization) { participatory_process.organization }

  describe "reporting_proposals_component" do
    let(:component) do
      create(:reporting_proposals_component,
             participatory_space: participatory_process,
             settings: {
               additional_buttons_show: additional_buttons_show,
               additional_button_text: { en: "My button" },
               additional_button_link: "https://#{organization.host}/processes/onion-dynamic/f/20/"
             })
    end

    before do
      switch_to_host(organization.host)
      visit_component
    end

    context "when the component does not have the additional button customized" do
      let(:additional_buttons_show) { false }

      it "does not have an additional button" do
        expect(page).not_to have_content("My button")
      end
    end

    context "when the component has the additional button customized" do
      let(:additional_buttons_show) { true }

      it "has an additional button" do
        expect(page).to have_content("My button")
        expect(page).to have_css("a[href='https://#{organization.host}/processes/onion-dynamic/f/20/']")
      end
    end
  end

  describe "proposal component" do
    let(:component) { create(:proposal_component, participatory_space: participatory_process) }

    context "when the component has the additional button customized" do
      let(:additional_buttons_show) { true }

      before do
        visit_component
      end

      it "does not have an additional button" do
        expect(page).not_to have_content("My button")
      end
    end
  end
end
