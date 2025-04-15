# frozen_string_literal: true

require "spec_helper"
require "system/shared/proposals_steps_examples"

describe "Reporting proposals overrides" do # rubocop:disable RSpec/DescribeClass
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:scope) { create(:scope, organization:) }
  let(:only_photos) { false }
  let(:attachments) { true }
  let!(:component) do
    create(:reporting_proposals_component,
           :with_extra_hashtags,
           participatory_space: participatory_process,
           suggested_hashtags:,
           automatic_hashtags:,
           settings: { scopes_enabled: true, attachments_allowed: attachments, only_photo_attachments: only_photos })
  end
  let(:automatic_hashtags) { "HashtagAuto1 HashtagAuto2" }
  let(:suggested_hashtags) { "HashtagSuggested1 HashtagSuggested2" }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:user_group) { create(:user_group, :verified, users: [user], organization:) }
  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }
  let(:proposal_category) { category }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let!(:another_category) { create(:category, participatory_space: participatory_process) }
  let(:address) { "Plaça Santa Jaume, 1, 08002 Barcelona" }
  let(:latitude) { 41.3825 }
  let(:longitude) { 2.1772 }

  before do
    stub_geocoding(address, [latitude, longitude])
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def fill_proposal(extra_fields: true, skip_address: false, skip_group: false, skip_scope: false, attach: false)
    within "#content" do
      fill_in :proposal_title, with: proposal_title
      fill_in :proposal_body, with: proposal_body

      if extra_fields
        select translated(proposal_category.name), from: :proposal_category_id
        fill_in :proposal_address, with: address
        check "#HashtagSuggested1"
        select user_group.name, from: :proposal_user_group_id unless skip_group
        select translated(scope.name), from: :proposal_scope_id unless skip_scope
      end

      check "proposal_has_no_address" if skip_address
    end

    if attach
      attach_file(:proposal_add_photos, Decidim::Dev.asset("city.jpeg"))
      dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("Exampledocument.pdf"))
    elsif manifest_name == "reporting_proposals"
      check "proposal_has_no_image"
    end

    within "#content" do
      find("*[type=submit]").click
    end
  end

  def complete_proposal(attach: false)
    within ".edit_proposal" do
      select translated(another_category.name), from: :proposal_category_id
      select user_group.name, from: :proposal_user_group_id
    end

    if attach
      attach_file(:proposal_add_photos, Decidim::Dev.asset("city.jpeg"))
      dynamically_attach_file(:proposal_documents, Decidim::Dev.asset("Exampledocument.pdf"))
    end

    within ".edit_proposal" do
      find("*[type=submit]").click
    end
  end

  context "when creating a new reporting proposal", :serves_geocoding_autocomplete do
    before do
      visit_component
      click_on "New proposal"
    end

    it_behaves_like "3 steps"
    it_behaves_like "prevents post if etiquette errors"
    it_behaves_like "customized form"
    it_behaves_like "map can be hidden"
    it_behaves_like "creates reporting proposal"
    it_behaves_like "reuses draft if exists"
    it_behaves_like "remove errors", continue: true
  end

  context "when editing a existing reporting proposal", :serves_geocoding_autocomplete do
    let!(:proposal) { create(:proposal, users: [user], address:, component:) }

    before do
      visit_component
      click_on translated(proposal.title), match: :first
      click_on "Edit proposal"
    end

    it_behaves_like "customized form"
    it_behaves_like "maintains errors"
    it_behaves_like "remove errors"

    context "when has an image" do
      let!(:proposal) { create(:proposal, :with_photo, users: [user], component:) }

      it_behaves_like "customized form"
      it_behaves_like "map can be hidden"
    end
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

    context "when creating" do
      before do
        visit_component
        click_on "New proposal"
      end

      it_behaves_like "4 steps"
      it_behaves_like "normal form"
      it_behaves_like "map can be shown", fill: true
      it_behaves_like "creates normal proposal"
    end

    context "when editing" do
      let!(:proposal) { create(:proposal, address: nil, latitude: nil, longitude: nil, users: [user], component:) }

      before do
        visit_component
        click_on translated(proposal.title)
        click_on "Edit proposal"
      end

      it_behaves_like "normal form"
      it_behaves_like "map can be shown"
    end
  end
end
