# frozen_string_literal: true

require "spec_helper"
require "system/shared/proposals_steps_examples"

describe "Reporting proposals overrides" do
  include_context "with a component"
  let(:manifest_name) { "reporting_proposals" }
  let!(:component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let(:user) { create(:user, :confirmed, organization:) }

  let!(:proposal_missed) { create(:proposal, title: "More sidewalks and less roadways", body: "Don't do greenwashing, I'm watching you", component:, longitude: longitude_missed, latitude: latitude_missed, published_at: published_missed) }
  let!(:proposal_far) { create(:proposal, title: "Completly unrelated text", body: "Bla bla bla bla bla bla bla bla", component:, longitude: longitude_far, latitude: latitude_far, published_at: published_far) }
  let!(:proposal_near) { create(:proposal, title: "A pink dragon is behing you", body: "Pink dragons don't exists, they say...", component:, longitude: longitude_near, latitude: latitude_near, published_at: published_near) }
  let!(:proposal_draft) { create(:proposal, :draft, title: "More sidewalks and less roads", body: "A very unique proposal", users: [user], component:, longitude:, latitude:) }

  # 41.4273° N, 2.1815° E (Canodrom, Barcelona)
  let(:latitude) { 41.4273 }
  let(:longitude) { 2.1815 }
  # 10 meters away
  let(:latitude_near) { 41.42737 }
  let(:longitude_near) { 2.18157 }
  # 20 meters away
  let(:latitude_far) { 41.42744 }
  let(:longitude_far) { 2.18165 }
  # 35 meters away
  let(:latitude_missed) { 41.42758 }
  let(:longitude_missed) { 2.1817 }

  let(:published_near) { 10.days.ago }
  let(:published_far) { 30.days.ago }
  let(:published_missed) { 50.days.ago }

  let(:component_path) { Decidim::EngineRouter.main_proxy(component) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit component_path.compare_proposal_path(proposal_draft)
  end

  shared_examples "compares using geocoding" do
    it "shows comparison text" do
      expect(page).to have_content("Nearby proposals (2)")
      expect(page).to have_content("These are proposals that are in a radius of 30m to the one you are creating.")
    end

    it "shows found proposals in order" do
      within ".compare-by-distance", match: :first do
        expect(page).to have_i18n_content(proposal_near.title)
        expect(page).to have_i18n_content("10m away")
      end
      within all(".compare-by-distance")[1] do
        expect(page).to have_i18n_content(proposal_far.title)
        expect(page).to have_i18n_content("20m away")
      end
      expect(page).not_to have_i18n_content(proposal_missed.title)
    end

    context "when the proposal is too old" do
      let(:published_near) { 61.days.ago }

      it "are excluded from the search" do
        expect(page).not_to have_i18n_content(proposal_near.title)
        expect(page).not_to have_i18n_content("10m away")
        expect(page).to have_i18n_content(proposal_far.title)
        expect(page).to have_i18n_content("20m away")
        expect(page).not_to have_i18n_content(proposal_missed.title)
      end
    end
  end

  shared_examples "compares using text" do
    it "shows comparison text" do
      expect(page).to have_no_content("Nearby proposals")
      expect(page).to have_content("Similar Proposals (1)")
      expect(page).to have_no_content("These are proposals that are in a radius")
    end

    it "shows proposals found by text" do
      expect(page).not_to have_i18n_content(proposal_near.title)
      expect(page).not_to have_i18n_content("10m away")
      expect(page).not_to have_i18n_content(proposal_far.title)
      expect(page).not_to have_i18n_content("20m away")
      expect(page).to have_i18n_content(proposal_missed.title)
    end
  end

  it_behaves_like "compares using geocoding"

  context "when no proposals are found" do
    let(:latitude) { 41.1 }
    let(:longitude) { 2.2 }

    it "shows no proposals found" do
      expect(page).to have_content("Publish your proposal")
      expect(page).to have_i18n_content(proposal_draft.title)
    end
  end

  context "when is a normal proposal component" do
    let!(:component) { create(:proposal_component, settings:, participatory_space: participatory_process) }
    let(:settings) { {} }

    it_behaves_like "compares using text"

    context "when geocoding comparison is active" do
      let(:settings) do
        {
          "geocoding_enabled" => true,
          "geocoding_comparison_enabled" => true
        }
      end

      it_behaves_like "compares using geocoding"

      context "when no proposals are found" do
        let(:latitude) { 41.1 }
        let(:longitude) { 2.2 }

        it "shows no proposals found" do
          expect(page).to have_content("Complete your proposal")
          expect(page).to have_i18n_content("Well done! No similar proposals found")
        end
      end
    end
  end
end
