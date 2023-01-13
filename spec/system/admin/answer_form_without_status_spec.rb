# frozen_string_literal: true

require "spec_helper"

describe "Answer form without status", type: :system do
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:component) { create :reporting_proposals_component, participatory_space: participatory_process }
  let!(:user) { create(:user, :confirmed, :admin, organization: organization) }
  let!(:proposal) { create(:proposal, component: component) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit manage_component_path(component)
  end

  context "when the proposal has no status" do
    before do
      find(".action-icon--show-proposal").click
    end

    it "status is not selected" do
      within "#proposal-answer" do
        expect(page).to have_no_checked_field
      end
    end

    it "does not have error 500, it has an alert" do
      click_button "Answer"

      expect(page).to have_content("There's been a problem answering this proposal")
    end
  end
end
