# frozen_string_literal: true

module Decidim::ReportingProposals
  describe AssignProposalValuatorsJob do
    subject do
      Decidim::Proposals::PublishProposal.new(proposal, user)
    end

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization: organization) }
    let(:category) { create(:category, participatory_space: participatory_process) }
    let!(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let!(:proposal) { create :proposal, :unpublished, component: component, category: category }
    let(:user) { proposal.authors.first }
    let(:admin_follower) { create :user, :admin, organization: organization }

    context "when publishing a proposal" do
      let(:data) do
        {
          affected_users: [],
          event_class: "Decidim::Proposals::PublishProposalEvent",
          extra: {},
          followers: [],
          force_send: false,
          resource: proposal
        }
      end
      let!(:follow) { create :follow, followable: proposal, user: admin_follower }

      it "broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end

      it "enqueues the job 3 times" do
        expect(Decidim::ReportingProposals::AssignProposalValuatorsJob).to receive(:perform_later)
          .with(data)
        expect(Decidim::ReportingProposals::AssignProposalValuatorsJob).to receive(:perform_later)
          .with(data.merge(
                  extra: {
                    participatory_space: true
                  }
                ))
        expect(Decidim::ReportingProposals::AssignProposalValuatorsJob).to receive(:perform_later)
          .with(data.merge(
                  extra: {
                    participatory_space: true,
                    type: "admin"
                  },
                  followers: [admin_follower]
                ))
        subject.call
      end
    end

    # rubocop:disable RSpec/AnyInstance
    context "when executing the job" do
      let(:valuator_user) { create(:user, :confirmed, organization: organization) }
      let!(:category_valuator) { create(:category_valuator, valuator_role: valuator_role, category: category) }
      let(:valuator_role) { create :participatory_process_user_role, role: "valuator", user: valuator_user, participatory_process: participatory_process }

      before do
        allow(Rails.logger).to receive(:info).at_least(:once)
      end

      shared_examples "assigns valuator once" do
        it "Assigns the valuator" do
          expect do
            perform_enqueued_jobs do
              subject.call
            end
          end.to change { Decidim::Proposals::ValuationAssignment.count }.by(1)
        end
      end

      it_behaves_like "assigns valuator once"

      context "when there's admin followers" do
        let!(:follow) { create :follow, followable: proposal, user: admin_follower }

        before do
          # simulate a race condition when checking for the assignment already done is not yet in the database
          allow_any_instance_of(Decidim::Proposals::Admin::AssignProposalsToValuator).to receive(:find_assignment).and_return(false)
        end

        it_behaves_like "assigns valuator once"
      end

      it "logs the action and sends an email" do
        perform_enqueued_jobs do
          subject.call
        end
        expect(Rails.logger).to have_received(:info).with(/Automatically assigned valuator #{valuator_user.name}/).once

        email = last_email
        expect(email.subject).to include("New proposals assigned to you for evaluation")
        expect(email.body.encoded).to include(ERB::Util.html_escape(proposal.title["en"]).gsub("&quot;", '"'))
      end

      context "and something wrong happened" do
        before do
          allow(Rails.logger).to receive(:warn).at_least(:once)
          allow_any_instance_of(Decidim::Proposals::Admin::ValuationAssignmentForm).to receive(:valid?).and_return(false)
        end

        it "logs the error and does not send any email" do
          perform_enqueued_jobs do
            subject.call
          end
          expect(Rails.logger).to have_received(:warn).with(/Couldn't automatically assign valuator #{valuator_user.name}/).once
          expect(last_email.subject).not_to include("New proposals assigned to you for evaluation")
        end
      end
    end
    # rubocop:enable RSpec/AnyInstance
  end
end
