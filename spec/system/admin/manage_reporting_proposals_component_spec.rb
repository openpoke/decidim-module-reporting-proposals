# frozen_string_literal: true

require "spec_helper"

describe "Managing reporting proposals component", type: :system do
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let!(:component) { create :reporting_proposals_component, participatory_space: participatory_process }
  let!(:user) { create(:user, :confirmed, :admin, organization: organization) }

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

  context "when managing standard proposals" do
    let!(:component) { create :proposal_component, participatory_space: participatory_process }

    it "does not hide readonly attributes" do
      expect(page).to have_content("Collaborative drafts enabled")
      expect(page).to have_content("Participatory texts enabled")
    end
  end
end
