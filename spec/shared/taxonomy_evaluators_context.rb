# frozen_string_literal: true

RSpec.shared_context "with taxonomy evaluators" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }
  let(:root_taxonomy) { create(:taxonomy, organization:) }
  let!(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, name: { en: "Roads and pavements" }) }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:proposals_component) { create(:proposal_component, participatory_space:, settings: { taxonomy_filters: [taxonomy_filter.id] }) }
  let(:evaluator) { create(:user, :confirmed, organization:, name: "Valentina Evaluator") }
  let(:another_evaluator) { create(:user, :confirmed, organization:, name: "Vicent Evaluator") }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end
end
