# frozen_string_literal: true

require "spec_helper"

describe "Send email to user with link", type: :system do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, component: component) }
  let(:participatory_space) { component.participatory_space }

  include_context "when managing a component as an admin"

  before do
    within find("tr", text: translated(proposal.title)) do
      click_link "Answer proposal"
    end
  end

  it "shows the sending email link" do
    expect(page).to have_content("Send an email to user")
  end

  it "has a link to send email with author's email" do
    expect(page).to have_selector("a[href*='mailto:#{proposal.creator_author.email}']")
  end
end
