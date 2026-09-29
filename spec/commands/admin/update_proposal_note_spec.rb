# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals::Admin
  describe UpdateProposalNote do
    let(:component) { create(:reporting_proposals_component) }
    let(:organization) { component.organization }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:form) { Decidim::Proposals::Admin::ProposalNoteForm.from_params(form_params).with_context(current_user: user, current_organization: organization) }

    let!(:note) { create(:proposal_note, proposal:, author: user) }
    let(:command) { described_class.new(form, note) }
    let!(:proposal) { create(:proposal, :official, component:) }

    describe "call" do
      let(:form_params) { { body: } }

      context "when the form is valid" do
        let(:body) { "Test body" }

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "updates the note" do
          expect { command.call }.to change { note.reload.body }.to("Test body")
        end

        it "traces the action", versioning: true do
          expect { command.call }.to change(Decidim::ActionLog, :count).by(1)
          expect(Decidim::ActionLog.last.action).to eq("update")
        end
      end

      context "when the body mentions a user" do
        let(:mentioned) { create(:user, :confirmed, organization:) }
        let(:body) { "Ping @#{mentioned.nickname}" }

        it "stores the mention as a global id" do
          command.call

          expect(note.reload.body).to eq("Ping #{mentioned.to_global_id}")
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
