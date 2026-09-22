# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals
  describe AdminLog::TaxonomyEvaluatorPresenter, type: :helper, versioning: true do
    subject { described_class.new(action_log, helper).present }

    let(:organization) { create(:organization) }
    let(:current_user) { create(:user, :confirmed, :admin, organization:) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy_name) { { "en" => "Parks and gardens" } }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, name: taxonomy_name) }
    let(:evaluator_user) { create(:user, :confirmed, organization:, name: "Eva Luator") }
    let(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, participatory_process:, user: evaluator_user) }
    let(:context) { { current_organization: organization, current_participatory_space: participatory_process, current_user: } }
    let(:action_log) { Decidim::ActionLog.last }

    before do
      helper.extend(Decidim::ApplicationHelper)
      helper.extend(Decidim::TranslationsHelper)
    end

    def update_evaluators(evaluator_role_ids)
      form = Admin::TaxonomyEvaluatorsForm.from_params(taxonomy_id: taxonomy.id, evaluator_role_ids:).with_context(context)
      Admin::UpdateTaxonomyEvaluators.new(form).call
    end

    context "when an evaluator has been assigned" do
      before { update_evaluators([evaluator_role.id]) }

      it "renders the explanation with the taxonomy name and the evaluator name in the diff" do
        expect(action_log.action).to eq("create")
        expect(subject).to include("Parks and gardens")
        expect(subject).to include("Eva Luator")
      end
    end

    context "when an evaluator has been unassigned" do
      before do
        update_evaluators([evaluator_role.id])
        update_evaluators([])
      end

      it "renders the taxonomy and evaluator names after the record is destroyed" do
        expect(action_log.action).to eq("delete")
        expect(TaxonomyEvaluator.count).to be_zero
        expect(subject).to include("Parks and gardens")
        expect(subject).to include("Eva Luator")
      end

      context "when the log entry predates the evaluator user name in the extra" do
        before do
          # ActionLog is a readonly model: strip the extra key through a relation update
          Decidim::ActionLog.where(id: action_log.id).update_all(extra: action_log.extra.except("evaluator_user_name")) # rubocop:disable Rails/SkipsModelValidations
          action_log.reload
        end

        it "resolves the evaluator name from the version payload" do
          expect(subject).to include("Eva Luator")
        end
      end

      context "when the taxonomy name contains HTML" do
        let(:taxonomy_name) { { "en" => "<script>alert(\"XSS\")</script>Parks" } }

        it "escapes the taxonomy name in the explanation" do
          expect(subject).not_to include("<script>")
          expect(subject).to include("&lt;script&gt;")
          expect(subject).to include("Parks")
        end
      end
    end
  end
end
