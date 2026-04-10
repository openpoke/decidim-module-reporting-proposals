# frozen_string_literal: true

require "spec_helper"

module Decidim::Proposals
  describe FilteredProposals do
    let(:organization) { create(:organization) }
    let(:participatory_process) { create(:participatory_process, organization:) }
    let(:component) { create(:proposal_component, participatory_space: participatory_process) }
    let(:another_component) { create(:proposal_component, participatory_space: participatory_process) }
    let(:reporting_component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
    let(:another_reporting_component) { create(:reporting_proposals_component, participatory_space: participatory_process) }

    let(:proposals) { create_list(:proposal, 2, component:) }
    let(:old_proposals) { create_list(:proposal, 3, component:, created_at: 10.days.ago) }
    let(:another_proposals) { create_list(:proposal, 4, component: another_component) }
    let(:reporting_proposals) { create_list(:proposal, 5, component: reporting_component) }
    let(:old_reporting_proposals) { create_list(:proposal, 6, component: reporting_component, created_at: 10.days.ago) }
    let(:another_reporting_proposals) { create_list(:proposal, 6, component: another_reporting_component) }

    it "returns proposals included in a collection of components" do
      expect(described_class.for([component, another_component])).to match_array proposals.concat(old_proposals, another_proposals)
    end

    it "returns proposals created in a date range" do
      expect(described_class.for([component, another_component], 2.weeks.ago, 1.week.ago)).to match_array old_proposals
    end

    context "when filtering by manifest_name" do
      it "returns proposals of the components with the given manifest_name" do
        expect(described_class.for([component, reporting_component, another_reporting_component], nil, nil, :reporting_proposals)).to match_array reporting_proposals.concat(old_reporting_proposals, another_reporting_proposals)
      end

      it "returns proposals of the components with the given manifest_name in a date range" do
        expect(described_class.for([component, reporting_component, another_reporting_component], 2.weeks.ago, 1.week.ago, :reporting_proposals)).to match_array old_reporting_proposals
      end
    end

    context "when components is an ActiveRecord::Relation" do
      let(:components) { Decidim::Component.where(id: [component.id, another_component.id]) }

      it "returns proposals included in a collection of components" do
        expect(described_class.for(components)).to match_array proposals.concat(old_proposals, another_proposals)
      end

      it "returns proposals created in a date range" do
        expect(described_class.for(components, 2.weeks.ago, 1.week.ago)).to match_array old_proposals
      end

      context "when filtering by manifest_name" do
        let(:components) { Decidim::Component.where(id: [component.id, reporting_component.id, another_reporting_component.id]) }

        it "returns proposals of the components with the given manifest_name" do
          expect(described_class.for(components, nil, nil, :reporting_proposals)).to match_array reporting_proposals.concat(old_reporting_proposals, another_reporting_proposals)
        end

        it "returns proposals of the components with the given manifest_name in a date range" do
          expect(described_class.for(components, 2.weeks.ago, 1.week.ago, :reporting_proposals)).to match_array old_reporting_proposals
        end
      end
    end
  end
end
