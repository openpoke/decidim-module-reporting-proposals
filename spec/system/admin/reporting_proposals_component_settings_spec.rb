# frozen_string_literal: true

require "spec_helper"

describe "Reporting proposals component settings" do
  let!(:component) { create(:reporting_proposals_component) }
  let(:organization) { component.organization }
  let!(:current_user) { create(:user, :confirmed, :admin, organization:) }

  let(:edit_component_path) do
    Decidim::EngineRouter.admin_proxy(component.participatory_space).edit_component_path(component.id)
  end

  before do
    switch_to_host(organization.host)
    login_as current_user, scope: :user
  end

  context "when proposal limit is empty" do
    it_behaves_like "has mandatory config setting", :proposal_limit
  end

  context "when vote limit per participant is empty" do
    it_behaves_like "has mandatory config setting", :vote_limit
  end

  context "when minimum votes per user is empty" do
    it_behaves_like "has mandatory config setting", :minimum_votes_per_user
  end

  context "when proposal_edit_time is empty" do
    it_behaves_like "has mandatory config setting", :edit_time
  end

  context "when comments_max_length is empty" do
    it_behaves_like "has mandatory config setting", :comments_max_length
  end

  context "when threshold_per_proposal is empty" do
    it_behaves_like "has mandatory config setting", :threshold_per_proposal
  end

  describe "default_sort_order choices" do
    let(:default_sort_order_container) { page.all(".default_sort_order_container").first }

    before do
      visit edit_component_path
    end

    context "when there are no proposals with coauthors" do
      it "does not include with_more_authors" do
        expect(default_sort_order_container).to have_no_content("With more authors")
      end
    end

    context "when there are proposals with coauthors" do
      let!(:proposal_with_coauthors) { create(:proposal, component:) }
      let!(:coauthorships) { create_list(:coauthorship, 2, coauthorable: proposal_with_coauthors) }

      before do
        visit edit_component_path
      end

      it "includes with_more_authors" do
        expect(default_sort_order_container).to have_content("With more authors")
      end
    end

    context "when there are no proposals with comments" do
      it "does not include most_commented" do
        expect(default_sort_order_container).to have_no_content("Most commented")
      end
    end

    context "when there are proposals with comments" do
      let!(:proposal_with_comments) { create(:proposal, component:, comments_count: 5) }

      before do
        visit edit_component_path
      end

      it "includes most_commented" do
        expect(default_sort_order_container).to have_content("Most commented")
      end
    end
  end
end
