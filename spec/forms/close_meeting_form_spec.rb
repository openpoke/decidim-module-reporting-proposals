# frozen_string_literal: true

require "spec_helper"

module Decidim::Meetings
  describe CloseMeetingForm do
    subject { described_class.from_model(meeting).with_context(context) }

    let(:meeting) { create(:meeting, component:) }
    let(:component) { create(:meeting_component) }
    let(:context) do
      {
        current_organization: meeting.organization,
        current_component: component,
        current_participatory_space: component.participatory_space
      }
    end

    let(:proposal_component) { create(:proposal_component, participatory_space: component.participatory_space) }
    let(:proposals) { create_list(:proposal, 3, component: proposal_component) }
    let(:reporting_component) { create(:reporting_proposals_component, participatory_space: component.participatory_space) }
    let(:reporting_proposals) { create_list(:proposal, 3, component: reporting_component) }

    before do
      meeting.link_resources(proposals + reporting_proposals, "proposals_from_meeting")
    end

    shared_examples "map_modal" do
      it "sets the proposals scope" do
        expect(subject.proposals).to match_array(proposals + reporting_proposals)
      end

      context "when the meeting is already linked to some proposals" do
        it "sets the proposal_ids" do
          expect(subject.proposal_ids).to match_array(proposals.map(&:id) + reporting_proposals.map(&:id))
        end
      end
    end

    it_behaves_like "map_modal"

    describe "admin/close_meeting_form" do
      subject { Admin::CloseMeetingForm.from_model(meeting).with_context(context) }

      it_behaves_like "map_modal"
    end
  end
end
