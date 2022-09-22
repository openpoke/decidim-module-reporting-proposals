# frozen_string_literal: true

require "spec_helper"
require "system/shared/proposals_steps_examples"

describe "Reporting proposals overrides", type: :system do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:scope) { create :scope, organization: organization }
  let!(:component) do
    create(:reporting_proposals_component,
           :with_extra_hashtags,
           participatory_space: participatory_process,
           suggested_hashtags: suggested_hashtags,
           automatic_hashtags: automatic_hashtags,
           settings: { scopes_enabled: true })
  end
  let(:automatic_hashtags) { "HashtagAuto1 HashtagAuto2" }
  let(:suggested_hashtags) { "HashtagSuggested1 HashtagSuggested2" }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:user_group) { create(:user_group, :verified, users: [user], organization: organization) }
  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }
  let(:proposal_category) { category }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let!(:another_category) { create :category, participatory_space: participatory_process }
  let(:address) { "Plaça Santa Jaume, 1, 08002 Barcelona" }
  let(:latitude) { 41.3825 }
  let(:longitude) { 2.1772 }
  let(:scope_picker) { select_data_picker(:proposal_scope_id) }

  before do
    stub_geocoding(address, [latitude, longitude])
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def fill_proposal(extra_fields: true, skip_address: false, skip_group: false, skip_scope: false, attach: false)
    within ".card__content form" do
      fill_in :proposal_title, with: proposal_title
      fill_in :proposal_body, with: proposal_body

      if extra_fields
        select translated(proposal_category.name), from: :proposal_category_id
        fill_in :proposal_address, with: address
        check "#HashtagSuggested1"
        select user_group.name, from: :proposal_user_group_id unless skip_group
        scope_pick scope_picker, scope unless skip_scope
      end

      check "proposal_has_no_address" if skip_address
      attach_file(:proposal_add_photos, Decidim::Dev.asset("city.jpeg")) if attach
      attach_file(:proposal_add_documents, Decidim::Dev.asset("Exampledocument.pdf")) if attach

      find("*[type=submit]").click
    end
  end

  def complete_proposal(attach: false)
    within ".card__content form" do
      select translated(another_category.name), from: :proposal_category_id
      select user_group.name, from: :proposal_user_group_id

      attach_file(:proposal_add_photos, Decidim::Dev.asset("city.jpeg")) if attach
      attach_file(:proposal_add_documents, Decidim::Dev.asset("Exampledocument.pdf")) if attach

      find("*[type=submit]").click
    end
  end

  context "when creating a new proposal", :serves_geocoding_autocomplete do
    before do
      visit_component
    end

    it_behaves_like "3 steps"
  end

  context "and component is a normal proposal", :serves_geocoding_autocomplete do
    let(:manifest_name) { "proposals" }
    let!(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_attachments_allowed,
             :with_geocoding_enabled,
             participatory_space: participatory_process)
    end

    before do
      visit_component
    end

    it_behaves_like "4 steps"
  end
end
