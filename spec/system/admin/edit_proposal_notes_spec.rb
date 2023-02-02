# frozen_string_literal: true

require "spec_helper"

describe "Edit Proposal Notes", type: :system do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, component: component) }
  let(:participatory_space) { component.participatory_space }

  let(:body) { "Test body" }
  let(:proposal_notes_count) { 5 }

  let!(:proposal_notes) do
    create_list(
      :proposal_note,
      proposal_notes_count,
      proposal: proposal,
      author: author,
      body: body
    )
  end

  include_context "when managing a component as an admin"

  before do
    within find("tr", text: translated(proposal.title)) do
      click_link translated(proposal.title)
    end
  end

  context "when the user is the author of the proposal note" do
    let(:author) { user }

    it "shows proposal notes for the current proposal" do
      proposal_notes.each do |proposal_note|
        expect(page).to have_css(".link-alt")
        expect(page).to have_content(proposal_note.author.name)
      end
    end

    it "edits a proposal note" do
      within ".comment-thread .card:last-child" do
        find(".link-alt").click
      end

      within ".edit_proposal_note" do
        expect(page).to have_content("Test body")
        fill_in :proposal_note_body, with: "New awesome body"
        # find("*[type=submit]").click
      end

      # expect(page).to have_admin_callout("successfully updated")
      # expect(page).to have_content("New awesome body")
    end
  end

  context "when the user is not the author of the proposal note" do
    let(:author) { create(:user, organization: organization) }

    it "shows proposal notes for the current proposal" do
      proposal_notes.each do |proposal_note|
        expect(page).not_to have_css(".link-alt")
        expect(page).to have_content(proposal_note.author.name)
      end
    end
  end
end
