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
               additional_button_link: "https://#{organization.host}/processes/onion-dynamic/f/20/",
               additional_buttons_for_show_proposal_show: additional_buttons_show,
               additional_button_for_show_proposal_text: { en: "My button 2" },
               additional_button_for_show_proposal_link: "https://#{organization.host}/processes/onion-dynamic/f/22/"
             })
    end
    let!(:reporting_proposal) { create(:proposal, component: component) }

    before do
      switch_to_host(organization.host)
      visit_component
    end

    context "when the component does not have the additional button customized" do
      let(:additional_buttons_show) { false }

      it "does not have an additional button" do
        expect(page).not_to have_content("My button")
      end

      it "does not have an additional button on show proposal page" do
        click_link reporting_proposal.title["en"]
        expect(page).not_to have_content("My button 2")
      end
    end

    context "when the component has the additional button customized" do
      let(:additional_buttons_show) { true }

      it "has an additional button" do
        expect(page).to have_content("My button")
        expect(page).to have_css("a[href='https://#{organization.host}/processes/onion-dynamic/f/20/']")
      end

      it "has an additional button on show proposal page" do
        click_link reporting_proposal.title["en"]
        expect(page).to have_content("My button 2")
        expect(page).to have_css("a[href='https://#{organization.host}/processes/onion-dynamic/f/22/']")
      end
    end
  end

  describe "proposal component" do
    let(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let!(:proposal) { create(:proposal, component: component) }

    context "when the component has the additional button customized" do
      let(:additional_buttons_show) { true }

      before do
        visit_component
      end

      it "does not have an additional button" do
        expect(page).not_to have_content("My button")
      end

      it "does not have an additional button on show proposal page" do
        click_link proposal.title["en"]
        expect(page).not_to have_content("My button 2")
      end
    end
  end
end
