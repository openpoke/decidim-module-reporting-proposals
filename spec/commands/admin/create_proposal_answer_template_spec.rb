# frozen_string_literal: true

require "spec_helper"

module Decidim::Templates
  describe Admin::CreateProposalAnswerTemplate do
    subject { described_class.new(form) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let(:component_constraint) { nil }
    let(:templatable) { Template.where(target: :proposal_answer).last.templatable }
    let(:form) do
      instance_double(
        Admin::ProposalAnswerTemplateForm,
        invalid?: false,
        valid?: true,
        current_user: user,
        current_organization: organization,
        select_component: false,
        name: { "en" => "name" },
        description: { "en" => "description" },
        proposal_state_id: 1,
        component_constraint:
      )
    end

    before { subject.call }

    context "when the form has no component constraint" do
      it "associates the organization" do
        expect(templatable).to eq(organization)
      end
    end

    context "when the constraint is a proposals component" do
      let(:component) { create(:proposal_component, organization:) }
      let(:component_constraint) { component.id }

      it "associates the component" do
        expect(templatable).to eq(component)
      end
    end

    context "when the constraint is a reporting proposals component" do
      let(:component) { create(:reporting_proposals_component, organization:) }
      let(:component_constraint) { component.id }

      it "associates the component" do
        expect(templatable).to eq(component)
      end
    end

    context "when the component belongs to another organization" do
      let(:component) { create(:reporting_proposals_component) }
      let(:component_constraint) { component.id }

      it "associates the organization" do
        expect(templatable).to eq(organization)
      end
    end
  end
end
