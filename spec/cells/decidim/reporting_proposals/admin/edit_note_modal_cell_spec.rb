# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  describe EditNoteModalCell, type: :cell do
    controller Decidim::Proposals::Admin::ProposalsController

    subject { cell(described_class, model, options).call }

    let(:proposal_note) { create(:proposal_note) }
    let(:model) { proposal_note }
    let(:options) { { modal_id: "editNoteModal" } }

    context "when rendering the note form" do
      it "renders the note body" do
        expect(subject).to have_content(proposal_note.body)
      end

      it "renders the note form" do
        expect(subject).to have_css("form#edit_proposal_note_#{proposal_note.id}")
      end

      it "has the modal id set to the specified value or default" do
        expect(subject).to have_css("##{options[:modal_id]}")
      end
    end

    context "when the proposal note exists" do
      it "renders the view" do
        expect(subject).to have_css("#editNoteModal")
      end

      it "assigns the correct proposal to the view" do
        expect(cell(described_class, model, options).proposal).to eq(Decidim::Proposals::Proposal.find(proposal_note.decidim_proposal_id))
      end

      it "assigns the correct proposal note body to the view" do
        expect(cell(described_class, model, options).note_body).to eq(proposal_note.body)
      end
    end
  end
end
