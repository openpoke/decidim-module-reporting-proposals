# frozen_string_literal: true

module Decidim::ReportingProposals
  # rubocop:disable RSpec/AnyInstance
  describe AssignProposalEvaluatorsJob do
    subject do
      Decidim::Proposals::PublishProposal.new(proposal, user)
    end

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let!(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let!(:proposal) { create(:proposal, :unpublished, users: [user], component:) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:admin_follower) { create(:user, :admin, organization:) }
    let!(:evaluator_user) { create(:user, :confirmed, organization:) }
    let!(:evaluator_role) do
      create(:participatory_process_user_role,
             user: evaluator_user,
             participatory_process: participatory_process,
             role: :evaluator)
    end

    shared_examples "assigns evaluator once" do |use_last_email: true|
      context "when there's admin followers" do
        let!(:follow) { create(:follow, followable: proposal, user: admin_follower) }

        before do
          allow(Rails.logger).to receive(:info)
          allow(Rails.logger).to receive(:warn)
          # simulate a race condition when checking for the assignment already done is not yet in the database
          allow_any_instance_of(Decidim::Proposals::Admin::AssignProposalsToEvaluator).to receive(:find_assignment).and_return(false)
        end

        it "Assigns the evaluator" do
          expect do
            perform_enqueued_jobs do
              subject.call
            end
          end.to change(Decidim::Proposals::EvaluationAssignment, :count).by(1)
        end
      end

      it "logs the action and sends an email" do
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:warn)
        perform_enqueued_jobs do
          subject.call
        end
        expect(Rails.logger).to have_received(:info).with(/Automatically assigned evaluator #{evaluator_user.name}/).once

        email = use_last_email ? last_email : emails.first
        expect(email.subject).to include("New proposals assigned to you for evaluation")
        expect(email.body.encoded).to include(ERB::Util.html_escape(proposal.title["en"]).gsub("&quot;", '"'))
      end

      context "and something wrong happened" do
        before do
          allow(Rails.logger).to receive(:warn).at_least(:once)
          allow_any_instance_of(Decidim::Proposals::Admin::EvaluationAssignmentForm).to receive(:valid?).and_return(false)
        end

        it "logs the error and does not send any email" do
          perform_enqueued_jobs do
            subject.call
          end
          expect(Rails.logger).to have_received(:warn).with(/Couldn't automatically assign evaluator #{evaluator_user.name}/).once
          expect(emails).to be_empty
        end
      end
    end

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
      let!(:follow) { create(:follow, followable: proposal, user: admin_follower) }

      it "broadcasts ok" do
        expect(subject.call).to broadcast(:ok)
      end

      it "enqueues the job 3 times" do
        expect(Decidim::ReportingProposals::AssignProposalEvaluatorsJob).to receive(:perform_later)
          .with(data)
        expect(Decidim::ReportingProposals::AssignProposalEvaluatorsJob).to receive(:perform_later)
          .with(data.merge(
                  extra: {
                    participatory_space: true
                  }
                ))
        expect(Decidim::ReportingProposals::AssignProposalEvaluatorsJob).to receive(:perform_later)
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

    context "when executing the job" do
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
      let(:evaluator_user) { create(:user, :confirmed, organization:) }
      let(:evaluator_role) { create(:participatory_process_user_role, role: "evaluator", user: evaluator_user, participatory_process:) }

      subject { -> { Decidim::ReportingProposals::AssignProposalEvaluatorsJob.perform_later(**data) } }

      before do
        allow(Rails.logger).to receive(:info).at_least(:once)
      end

      it_behaves_like "assigns evaluator once"
    end
  end
  # rubocop:enable RSpec/AnyInstance
end
