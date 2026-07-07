# frozen_string_literal: true

require "spec_helper"
require "decidim/assemblies/test/factories"

module Decidim::ReportingProposals
  # rubocop:disable RSpec/AnyInstance
  describe AssignProposalEvaluatorsJob do
    subject(:publish_command) { Decidim::Proposals::PublishProposal.new(proposal, user) }

    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
    let!(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let!(:proposal) { create(:proposal, :unpublished, users: [user], component:, taxonomies: [taxonomy]) }
    let(:user) { create(:user, :confirmed, organization:) }
    let(:admin_follower) { create(:user, :admin, organization:) }
    let(:evaluator_user) { create(:user, :confirmed, organization:) }
    let(:evaluator_role) { create(:participatory_process_user_role, role: "evaluator", user: evaluator_user, participatory_process:) }

    shared_examples "assigns evaluator once" do
      context "when there's admin followers" do
        let!(:follow) { create(:follow, followable: proposal, user: admin_follower) }

        before do
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

      it "logs the action and notifies the evaluator" do
        allow(Decidim::EventsManager).to receive(:publish).and_call_original

        perform_enqueued_jobs do
          subject.call
        end

        expect(Rails.logger).to have_received(:info).with(/Automatically assigned evaluators #{evaluator_user.name}/).once
        expect(Decidim::EventsManager).to have_received(:publish).with(
          event: "decidim.events.proposals.admin.proposal_assigned_to_evaluator",
          event_class: Decidim::Proposals::Admin::ProposalAssignedToEvaluatorEvent,
          resource: proposal,
          affected_users: [evaluator_user]
        ).once
      end

      context "and something wrong happened" do
        before do
          allow(Rails.logger).to receive(:warn)
          allow_any_instance_of(Decidim::Proposals::Admin::EvaluationAssignmentForm).to receive(:valid?).and_return(false)
        end

        it "logs the error and does not notify the evaluator" do
          allow(Decidim::EventsManager).to receive(:publish).and_call_original

          perform_enqueued_jobs do
            subject.call
          end

          expect(Rails.logger).to have_received(:warn).with(/Couldn't automatically assign evaluators #{evaluator_user.name}/).once
          expect(Decidim::EventsManager).not_to have_received(:publish)
            .with(hash_including(event: "decidim.events.proposals.admin.proposal_assigned_to_evaluator"))
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
      let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role:) }
      let!(:unmapped_evaluator_role) { create(:participatory_process_user_role, role: "evaluator", user: create(:user, :confirmed, organization:), participatory_process:) }

      before do
        allow(Rails.logger).to receive(:info)
      end

      it_behaves_like "assigns evaluator once"

      describe "traceability author" do
        let(:job_data) { { resource: proposal, event_class: "Decidim::Proposals::PublishProposalEvent", extra: { participatory_space: true } } }

        it "attributes the action log to the automation bot user" do
          described_class.perform_now(job_data)

          action_log = Decidim::ActionLog.find_by(resource_type: "Decidim::Proposals::EvaluationAssignment")
          expect(action_log).to be_present
          expect(action_log.user.name).to eq("Automatic assignment")
          expect(action_log.user.email).to eq(Decidim::ReportingProposals.automation_user_email)
          expect(action_log.user).not_to be_deleted
          expect(action_log.user).not_to be_managed
        end

        it "creates the bot user once and reuses it on subsequent runs" do
          expect { described_class.perform_now(job_data) }.to change(Decidim::User, :count).by(1)

          proposal.evaluation_assignments.destroy_all
          expect { described_class.perform_now(job_data) }.not_to change(Decidim::User, :count)
        end
      end

      context "when the proposal has no taxonomies" do
        let!(:proposal) { create(:proposal, :unpublished, users: [user], component:) }

        it "does not assign any evaluator" do
          expect do
            perform_enqueued_jobs { subject.call }
          end.not_to change(Decidim::Proposals::EvaluationAssignment, :count)
        end
      end

      context "when two taxonomies are mapped to the same evaluator" do
        let(:other_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
        let!(:proposal) { create(:proposal, :unpublished, users: [user], component:, taxonomies: [taxonomy, other_taxonomy]) }
        let!(:other_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy: other_taxonomy, evaluator_role:) }

        it "assigns the evaluator only once" do
          expect do
            perform_enqueued_jobs { subject.call }
          end.to change(Decidim::Proposals::EvaluationAssignment, :count).by(1)
        end
      end

      context "when the taxonomy is mapped to two evaluators" do
        let(:other_evaluator_role) { create(:participatory_process_user_role, role: "evaluator", user: create(:user, :confirmed, organization:), participatory_process:) }
        let!(:other_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: other_evaluator_role) }

        it "assigns both evaluators with a single command call" do
          expect(Decidim::Proposals::Admin::AssignProposalsToEvaluator).to receive(:call).once.and_call_original

          expect do
            perform_enqueued_jobs { subject.call }
          end.to change(Decidim::Proposals::EvaluationAssignment, :count).by(2)
        end
      end

      context "when the assignment is only on the parent taxonomy" do
        let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy: root_taxonomy, evaluator_role:) }

        it_behaves_like "assigns evaluator once"
      end

      context "when the assignment is only on the root and the proposal is tagged with a grandchild" do
        let(:grandchild_taxonomy) { create(:taxonomy, parent: taxonomy, organization:) }
        let!(:proposal) { create(:proposal, :unpublished, users: [user], component:, taxonomies: [grandchild_taxonomy]) }
        let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy: root_taxonomy, evaluator_role:) }

        it_behaves_like "assigns evaluator once"
      end

      context "when both the taxonomy and its parent have assignments" do
        let(:parent_evaluator_role) { create(:participatory_process_user_role, role: "evaluator", user: create(:user, :confirmed, organization:), participatory_process:) }
        let!(:parent_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy: root_taxonomy, evaluator_role: parent_evaluator_role) }

        it "assigns only the evaluators of the taxonomy itself" do
          expect do
            perform_enqueued_jobs { subject.call }
          end.to change(Decidim::Proposals::EvaluationAssignment, :count).by(1)

          expect(Decidim::Proposals::EvaluationAssignment.last.evaluator_role).to eq(evaluator_role)
        end
      end

      context "when no taxonomy in the chain has assignments" do
        let(:unmapped_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
        let!(:proposal) { create(:proposal, :unpublished, users: [user], component:, taxonomies: [unmapped_taxonomy]) }

        it "does not assign any evaluator" do
          expect do
            perform_enqueued_jobs { subject.call }
          end.not_to change(Decidim::Proposals::EvaluationAssignment, :count)
        end
      end

      context "when the mapped role belongs to another participatory space" do
        let(:other_participatory_process) { create(:participatory_process, organization:) }
        let(:evaluator_role) { create(:participatory_process_user_role, role: "evaluator", user: evaluator_user, participatory_process: other_participatory_process) }

        it "does not assign any evaluator" do
          expect do
            perform_enqueued_jobs { subject.call }
          end.not_to change(Decidim::Proposals::EvaluationAssignment, :count)
        end
      end

      context "when another space has an assignment on the taxonomy and this space only on the parent" do
        let(:other_participatory_process) { create(:participatory_process, organization:) }
        let(:other_space_role) { create(:participatory_process_user_role, role: "evaluator", user: create(:user, :confirmed, organization:), participatory_process: other_participatory_process) }
        let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy:, evaluator_role: other_space_role) }
        let!(:parent_taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy: root_taxonomy, evaluator_role:) }

        # the other space's child-level assignment must not block this space's
        # inheritance from the parent
        it_behaves_like "assigns evaluator once"
      end

      context "when the mapped role belongs to a parent assembly" do
        let(:parent_assembly) { create(:assembly, organization:) }
        let(:child_assembly) { create(:assembly, parent: parent_assembly, organization:) }
        let!(:component) { create(:proposal_component, participatory_space: child_assembly) }
        let(:evaluator_role) { create(:assembly_user_role, role: "evaluator", user: evaluator_user, assembly: parent_assembly) }

        it "does not assign any evaluator" do
          expect do
            perform_enqueued_jobs { subject.call }
          end.not_to change(Decidim::Proposals::EvaluationAssignment, :count)
        end
      end
    end

    context "when the taxonomy has no mapped evaluators" do
      let!(:evaluator_role) { create(:participatory_process_user_role, role: "evaluator", user: evaluator_user, participatory_process:) }

      it "does not assign any evaluator" do
        expect do
          perform_enqueued_jobs { subject.call }
        end.not_to change(Decidim::Proposals::EvaluationAssignment, :count)
      end
    end

    describe "update taxonomies" do
      subject(:update_taxonomies_command) { Decidim::Proposals::Admin::UpdateProposalTaxonomies.new([new_taxonomy.id], [proposal.id], organization) }

      let(:new_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }

      context "when changing taxonomies" do
        let(:data) do
          {
            affected_users: [user],
            event_class: "Decidim::Proposals::UpdateProposalTaxonomiesEvent",
            extra: {},
            followers: [],
            force_send: false,
            resource: proposal
          }
        end
        let!(:follow) { create(:follow, followable: proposal, user: admin_follower) }

        it "broadcasts ok" do
          expect(subject.call).to broadcast(:update_resources_taxonomies)
        end

        it "enqueues the job 1 time" do
          expect(Decidim::ReportingProposals::AssignProposalEvaluatorsJob).to receive(:perform_later)
            .with(data)
          subject.call
        end
      end

      context "when executing the job" do
        let!(:taxonomy_evaluator) { create(:taxonomy_evaluator, taxonomy: new_taxonomy, evaluator_role:) }

        before do
          allow(Rails.logger).to receive(:info)
        end

        it_behaves_like "assigns evaluator once"
      end
    end
  end
  # rubocop:enable RSpec/AnyInstance
end
