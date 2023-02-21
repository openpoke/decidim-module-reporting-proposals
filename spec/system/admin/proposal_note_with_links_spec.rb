# frozen_string_literal: true

require "spec_helper"

describe "Proposal note with links", type: :system do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, component: component) }
  let(:participatory_space) { component.participatory_space }
  let(:body) { "Awesome body with link: https://github.com" }
  let!(:proposal_note) { create(:proposal_note, proposal: proposal, body: body) }

  include_context "when managing a component as an admin"

  before do
    within find("tr", text: translated(proposal.title)) do
      click_link "Answer proposal"
    end
  end

  it "shows the link and opens it in a new tab" do
    within ".comment__content" do
      expect(page).to have_selector("a[href='https://github.com'][target='_blank']", text: "https://github.com")
      find("a[href='https://github.com']", text: "https://github.com").click
    end
  end
end
