# frozen_string_literal: true

require "spec_helper"

describe "Edit Proposal Notes" do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let(:manifest_name) { "proposals" }
  let(:proposal) { create(:proposal, component:) }
  let(:participatory_space) { component.participatory_space }

  let(:body) { "Test body" }
  let(:proposal_notes_count) { 5 }

  let!(:proposal_notes) do
    create_list(
      :proposal_note,
      proposal_notes_count,
      proposal:,
      author:,
      body:
    )
  end

  include_context "when managing a component as an admin"

  before do
    within "tr", text: translated(proposal.title) do
      click_link_or_button translated(proposal.title)
    end
  end

  context "when the user is the author of the proposal note" do
    let(:author) { user }

    it "shows proposal notes for the current proposal" do
      click_link_or_button "Private notes"
      proposal_notes.each do |proposal_note|
        expect(page).to have_button("Edit note")
        expect(page).to have_content(proposal_note.author.name)
      end
    end

    it "edits a proposal note" do
      click_link_or_button "Private notes"
      within ".comment:last-child" do
        click_link_or_button "Edit note"
      end

      within ".edit_proposal_note" do
        expect(page).to have_content("Test body")
        fill_in :proposal_note_body, with: "New awesome body"
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully updated")
      click_link_or_button "Private notes"
      expect(page).to have_content("New awesome body")
    end
  end

  context "when the user is not the author of the proposal note" do
    let(:author) { create(:user, organization:) }

    it "shows proposal notes for the current proposal" do
      click_link_or_button "Private notes"
      proposal_notes.each do |proposal_note|
        expect(page).to have_no_button("Edit note")
        expect(page).to have_content(proposal_note.author.name)
      end
    end
  end

  context "when the note has not been edited" do
    let(:author) { user }

    it "does not display the edited status" do
      click_link_or_button "Private notes"
      expect(page).to have_no_content("Edited")
    end
  end

  context "when the proposal note has been edited" do
    let(:author) { user }

    before do
      proposal_notes.last.update(body: "Edited body")
      visit current_path
    end

    it "displays the edited status" do
      click_link_or_button "Private notes"
      expect(page).to have_content("Edited")
      expect(page).to have_content(proposal_notes.last.updated_at.strftime("%d/%m/%Y %H:%M"))
    end
  end
end
