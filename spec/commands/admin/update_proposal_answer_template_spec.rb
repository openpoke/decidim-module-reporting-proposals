# frozen_string_literal: true

require "spec_helper"

module Decidim::Templates
  describe Admin::UpdateProposalAnswerTemplate do
    subject { described_class.new(template, form, user) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :admin, :confirmed, organization:) }
    let!(:template) { create(:template, target: :proposal_answer, organization:) }
    let(:component_constraint) { nil }
    let(:form) do
      instance_double(
        Admin::ProposalAnswerTemplateForm,
        invalid?: false,
        valid?: true,
        current_user: user,
        current_organization: organization,
        name: { "en" => "name" },
        description: { "en" => "description" },
        proposal_state_id: 1,
        component_constraint:
      )
    end

    before { subject.call }

    context "when the form has no component constraint" do
      it "removes the association" do
        expect(template.reload.templatable).to be_nil
      end
    end

    context "when the constraint is a proposals component" do
      let(:component) { create(:proposal_component, organization:) }
      let(:component_constraint) { component.id }

      it "associates the component" do
        expect(template.reload.templatable).to eq(component)
      end
    end

    context "when the constraint is a reporting proposals component" do
      let(:component) { create(:reporting_proposals_component, organization:) }
      let(:component_constraint) { component.id }

      it "associates the component" do
        expect(template.reload.templatable).to eq(component)
      end
    end

    context "when the component belongs to another organization" do
      let(:component) { create(:reporting_proposals_component) }
      let(:component_constraint) { component.id }

      it "does not associate the component" do
        expect(template.reload.templatable).to be_nil
      end
    end
  end
end
