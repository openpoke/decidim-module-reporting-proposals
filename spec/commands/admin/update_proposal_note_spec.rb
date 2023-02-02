# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals::Admin
  describe UpdateProposalNote do
    let(:form_klass) { Decidim::ReportingProposals::Admin::ProposalPhotoForm }

    let(:component) { create(:reporting_proposals_component) }
    let(:organization) { component.organization }
    let(:user) { create :user, :admin, :confirmed, organization: organization }
    let(:form) do
      Decidim::Proposals::Admin::ProposalNoteForm.from_params(
        form_params
      )
    end

    let!(:note) { create(:proposal_note, proposal: proposal, author: user) }
    let(:command) { described_class.new(form, note) }
    let!(:proposal) { create :proposal, :official, component: component }

    describe "call" do
      let(:form_params) do
        { body: body }
      end

      context "when the form is valid" do
        let(:body) { "Test body" }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the note" do
          expect do
            command.call
          end.to change(note, :body)
        end
      end

      context "when file_field :body is left blank" do
        let(:body) { "" }

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
