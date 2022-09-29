# frozen_string_literal: true

require "spec_helper"

describe "User location button", type: :system do
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
  let!(:user) { create(:user, :admin, :confirmed, organization: organization) }
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
  let(:all_manifests) { [:proposals, :meetings, :reporting_proposals] }
  let(:manifests) { all_manifests }

  before do
    stub_geocoding(address, [latitude, longitude])
    allow(Decidim::ReportingProposals).to receive(:show_my_location_button).and_return(manifests)
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  shared_examples "uses device location" do
    it "has my location button" do
      expect(page).to have_button("Use my location")
    end

    context "when option disabled" do
      let(:manifests) { all_manifests - [component.manifest_name.to_sym] }

      it "does not has the location button" do
        expect(page).not_to have_button("Use my location")
      end
    end
  end

  describe "#reporting_proposals", :serves_geocoding_autocomplete do
    before do
      visit_component
      click_link "New proposal"
    end

    it_behaves_like "uses device location"
  end

  context "when admin", :serves_geocoding_autocomplete do
    before do
      visit manage_component_path(component)
      click_link "New proposal"
    end

    it_behaves_like "uses device location"
  end

  describe "#proposals", :serves_geocoding_autocomplete do
    let(:manifest_name) { "proposals" }
    let!(:component) do
      create(:proposal_component,
             :with_creation_enabled,
             :with_geocoding_enabled,
             participatory_space: participatory_process)
    end
    let(:proposal) { create(:proposal, :draft, component: component, users: [user]) }

    before do
      visit_component
      visit "#{Decidim::EngineRouter.main_proxy(component).proposal_path(proposal)}/complete"
      check "proposal_has_address"
    end

    it_behaves_like "uses device location"

    context "when admin", :serves_geocoding_autocomplete do
      before do
        visit manage_component_path(component)
        click_link "New proposal"
      end

      it_behaves_like "uses device location"
    end
  end

  describe "#meetings", :serves_geocoding_autocomplete do
    let(:manifest_name) { "meetings" }
    let!(:component) do
      create(:meeting_component,
             :with_creation_enabled,
             participatory_space: participatory_process)
    end

    before do
      visit_component
      click_link "New meeting"
      select "In person", from: :meeting_type_of_meeting
    end

    it_behaves_like "uses device location"

    context "when admin", :serves_geocoding_autocomplete do
      before do
        visit manage_component_path(component)
        click_link "New meeting"
        select "In person", from: :meeting_type_of_meeting
      end

      it_behaves_like "uses device location"
    end
  end
end
