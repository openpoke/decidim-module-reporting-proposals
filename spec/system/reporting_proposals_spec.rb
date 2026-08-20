# frozen_string_literal: true

require "spec_helper"
require "system/shared/proposals_steps_examples"

describe "Reporting proposals overrides" do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:scope) { create(:scope, organization:) }
  let(:attachments) { true }
  let(:taxonomy_filter) { create(:taxonomy_filter, root_taxonomy:, participatory_space_manifests: [participatory_space.manifest.name]) }
  let!(:taxonomy_filter_item) { create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy) }
  let!(:component) do
    create(:reporting_proposals_component,
           participatory_space: participatory_process,
           settings: { taxonomy_filters: [taxonomy_filter.id], attachments_allowed: attachments })
  end
  let(:automatic_hashtags) { "HashtagAuto1 HashtagAuto2" }
  let(:suggested_hashtags) { "HashtagSuggested1 HashtagSuggested2" }
  let!(:user) { create(:user, :confirmed, organization:) }
  let(:proposal_title) { "More sidewalks and less roads" }
  let(:proposal_body) { "Cities need more people, not more cars" }
  let(:proposal) { Decidim::Proposals::Proposal.last }
  let(:address) { "Plaça Santa Jaume, 1, 08002 Barcelona" }
  let(:latitude) { 41.3825 }
  let(:longitude) { 2.1772 }

  before do
    stub_geocoding(address, [latitude, longitude])
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  def fill_proposal(extra_fields: true, skip_address: false, attach: false, submit: true)
    within "#content" do
      fill_in :proposal_title, with: proposal_title
      fill_in :proposal_body, with: proposal_body

      fill_in :proposal_address, with: address if extra_fields

      check "proposal_has_no_address" if skip_address
    end
    if attach
      page.execute_script("document.querySelectorAll('[data-filename]').forEach(el => el.remove());")
      # Single unified attachments upload now takes both the image and the document.
      dynamically_attach_file(:proposal_attachments, Decidim::Dev.asset("city.jpeg"))
      dynamically_attach_file(:proposal_attachments, Decidim::Dev.asset("Exampledocument.pdf"))
    elsif manifest_name == "reporting_proposals"
      check "proposal_has_no_attachments"
    end

    if submit
      within "#content" do
        find("*[type=submit]").click
      end
    end
  end
  context "when creating a new reporting proposal", :serves_geocoding_autocomplete do
    before do
      visit_component
      click_on "New proposal"
    end

    it_behaves_like "prevents post if etiquette errors"
    it_behaves_like "customized form"
    it_behaves_like "map can be hidden"
    it_behaves_like "creates reporting proposal"
    it_behaves_like "reuses draft if exists"
    it_behaves_like "remove errors", continue: true

    it "does not mark the file input of the upload modal as required" do
      expect(page).to have_field("proposal[add_attachments][]", type: "file", visible: :all)
      expect(page).to have_no_css("input[type=file][required]", visible: :all)
    end

    it "shows a visible error when attachments are required and none are given" do
      within "#content" do
        fill_in :proposal_title, with: proposal_title
        fill_in :proposal_body, with: proposal_body
        fill_in :proposal_address, with: address
        uncheck "proposal_has_no_attachments"

        find("*[type=submit]").click
      end

      expect(page).to have_css("form.new_proposal")
      expect(page).to have_css(".gallery__container .form-error", text: /cannot be blank/i)
    end
  end

  context "when editing a existing reporting proposal", :serves_geocoding_autocomplete do
    let!(:proposal) { create(:proposal, users: [user], address:, component:) }

    before do
      visit_component
      click_on translated(proposal.title), match: :first
      find("#dropdown-trigger-resource-#{proposal.id}").click
      click_on "Edit"
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

      it_behaves_like "normal form"
      it_behaves_like "map can be shown", fill: true
      it_behaves_like "creates normal proposal"
    end

    context "when editing" do
      let!(:proposal) { create(:proposal, address: nil, latitude: nil, longitude: nil, users: [user], component:) }

      before do
        visit_component
        click_on translated(proposal.title)
        find("#dropdown-trigger-resource-#{proposal.id}").click
        click_on "Edit"
      end

      it_behaves_like "normal form"
      it_behaves_like "map can be shown"
    end
  end
end
