# frozen_string_literal: true

require "spec_helper"

module Decidim::ReportingProposals::Admin
  describe TaxonomyEvaluatorsHelper do
    let(:taxonomy) { instance_double(Decidim::Taxonomy, parent_ids:) }

    describe "#taxonomy_indent_class" do
      context "when the taxonomy is a root" do
        let(:parent_ids) { [] }

        it "returns no indentation" do
          expect(helper.taxonomy_indent_class(taxonomy)).to eq("")
        end
      end

      context "when the taxonomy is nested" do
        let(:parent_ids) { [1, 2] }

        it "indents proportionally to the depth" do
          expect(helper.taxonomy_indent_class(taxonomy)).to eq("pl-12")
        end
      end
    end
  end
end
