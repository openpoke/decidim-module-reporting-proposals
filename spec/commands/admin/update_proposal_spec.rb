# frozen_string_literal: true

require "spec_helper"

describe Decidim::ReportingProposals::Admin::UpdateProposal do
  let(:form_klass) { Decidim::ReportingProposals::Admin::ProposalPhotoForm }

  let(:component) { create(:reporting_proposals_component) }
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_participatory_space: component.participatory_space,
      current_user: user,
      current_component: component
    )
  end

  let!(:proposal) { create :proposal, :official, component: component }

  let(:uploaded_photos) { [] }
  let(:current_photos) { [] }

  describe "call" do
    let(:form_params) do
      {
        photos: current_photos,
        add_photos: uploaded_photos
      }
    end

    let(:command) do
      described_class.new(form, proposal)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create a proposal" do
        expect do
          command.call
        end.not_to change(proposal.photos, :count)
      end
    end

    describe "admin manages resource gallery" do

      context "when managing images" do
        let(:uploaded_photos) do
          [
            Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
            Decidim::Dev.test_file("city2.jpeg", "image/jpeg")
          ]
        end
        let(:current_photos) { [] }

        # it "add photos to proposal" do
        #   command.call
        #
        #   expect(proposal.photos.count).to eq(2)
        #   last_attachment = Decidim::Attachment.last
        #   expect(last_attachment.attached_to).to eq(proposal)
        # end

        context "when file_field :add_photos is left blank" do
          let(:uploaded_photos) { [] }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
