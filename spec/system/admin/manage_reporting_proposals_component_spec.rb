# frozen_string_literal: true

require "spec_helper"

describe "Managing reporting proposals component" do
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }

  def edit_component_path(component)
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    visit edit_component_path(component)
  end

  it "hides readonly attributes" do
    expect(page).not_to have_content("Collaborative drafts enabled")
    expect(page).not_to have_content("Participatory texts enabled")
  end

  it "has default values for settings" do
    expect(page).to have_content("Compare proposals by distance proximity")
    expect(page).to have_checked_field("component_settings_geocoding_comparison_enabled")
    expect(page).to have_content("Maximum radius (in meters)")
    expect(page).to have_field("component_settings_geocoding_comparison_radius", with: 30)
    expect(page).to have_content("Compare only proposal made in the last X days")
    expect(page).to have_field("component_settings_geocoding_comparison_newer_than", with: 60)
    expect(page).to have_content("After how many days a not-answered proposal is considered overdue")
    expect(page).to have_field("component_settings_unanswered_proposals_overdue", with: 7)
    expect(page).to have_content("After how many days a proposal in its evaluating state is considered overdue")
    expect(page).to have_field("component_settings_evaluating_proposals_overdue", with: 3)
    expect(page).to have_content("Allow admins and valuators to edit photos when answering proposals")
    expect(page).to have_checked_field("component_settings_proposal_photo_editing_enabled")
  end

  context "when managing standard proposals" do
    let!(:component) { create(:proposal_component, participatory_space: participatory_process) }

    it "does not hide readonly attributes" do
      expect(page).to have_content("Collaborative drafts enabled")
      expect(page).to have_content("Participatory texts enabled")
    end

    it "has default values for settings" do
      expect(page).to have_content("Compare proposals by distance proximity")
      expect(page).to have_unchecked_field("component_settings_geocoding_comparison_enabled")
      expect(page).to have_content("Maximum radius (in meters)")
      expect(page).to have_field("component_settings_geocoding_comparison_radius", with: 30)
      expect(page).to have_content("Compare only proposal made in the last X days")
      expect(page).to have_field("component_settings_geocoding_comparison_newer_than", with: 60)
      expect(page).to have_content("After how many days a not-answered proposal is considered overdue")
      expect(page).to have_field("component_settings_unanswered_proposals_overdue", with: 7)
      expect(page).to have_content("After how many days a proposal in its evaluating state is considered overdue")
      expect(page).to have_field("component_settings_evaluating_proposals_overdue", with: 3)
      expect(page).to have_content("Allow admins and valuators to edit photos when answering proposals")
      expect(page).to have_unchecked_field("component_settings_proposal_photo_editing_enabled")
    end
  end
end
