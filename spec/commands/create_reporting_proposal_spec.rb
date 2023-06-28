# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ReportingProposals
    describe CreateReportingProposal do
      let(:form_klass) { ProposalForm }
      let(:component) { create(:reporting_proposals_component) }
      let(:organization) { component.organization }
      let(:user) { create :user, :admin, :confirmed, organization: organization }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_user: user,
          current_organization: organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        )
      end

      let(:author) { create(:user, organization: organization) }

      let(:user_group) do
        create(:user_group, :verified, organization: organization, users: [author])
      end

      # let(:uploaded_files) do
      #   [
      #     Decidim::Dev.test_file("Exampledocument.pdf", "application/pdf")
      #   ]
      # end
      let(:uploaded_files) do
        [
          {
            file: upload_test_file(Decidim::Dev.asset("Exampledocument.pdf"), content_type: "application/pdf")
          }
        ]
      end

      let(:uploaded_photos) do
        [
          {
            file: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg"))
          }
        ]
      end
      let(:latitude) { 40.1234 }
      let(:longitude) { 2.1234 }
      let(:title) { "A reasonable proposal title" }
      let(:body) { "A reasonable proposal body" }
      let(:address) { "Some address" }
      let(:has_no_address) { false }
      let(:form_params) do
        {
          title: title,
          body: body,
          address: address,
          has_no_address: has_no_address,
          user_group_id: user_group.try(:id),
          add_photos: uploaded_photos,
          add_documents: uploaded_files
        }
      end

      let(:command) do
        described_class.new(form, author)
      end

      let(:proposal) { Decidim::Proposals::Proposal.last }

      before do
        stub_geocoding(address, [latitude, longitude])
      end

      describe "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "broadcasts invalid" do
          expect { command.call }.to broadcast(:invalid)
        end

        it "doesn't create a proposal" do
          expect do
            command.call
          end.not_to change(Decidim::Proposals::Proposal, :count)
        end
      end

      describe "when the form is valid" do
        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end

        it "creates a new proposal" do
          expect do
            command.call
          end.to change(Decidim::Proposals::Proposal, :count).by(1)
        end

        it "sets the body and title as i18n" do
          command.call

          expect(proposal.title).to be_kind_of(Hash)
          expect(proposal.title[I18n.locale.to_s]).to eq form_params[:title]
          expect(proposal.body).to be_kind_of(Hash)
          expect(proposal.body[I18n.locale.to_s]).to eq form_params[:body]
        end

        it "sets the latitude and longitude" do
          command.call

          expect(proposal.latitude).to eq(latitude)
          expect(proposal.longitude).to eq(longitude)
        end

        context "when address is empty" do
          let(:address) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          context "when no address required" do
            let(:has_no_address) { true }

            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "does not set the latitude and longitude" do
              command.call

              expect(proposal.latitude).to be_blank
              expect(proposal.longitude).to be_blank
            end
          end
        end

        context "with a proposal limit" do
          let(:component) do
            create(:reporting_proposals_component, settings: { "proposal_limit" => 2 })
          end

          it "checks the author doesn't exceed the amount of proposals" do
            expect { command.call }.to broadcast(:ok)
            expect { command.call }.to broadcast(:ok)
            expect { command.call }.to broadcast(:invalid)
          end
        end

        it "creates multiple atachments for the proposal" do
          expect { command.call }.to change(Decidim::Attachment, :count).by(2)
          last_attachment = Decidim::Attachment.last
          expect(last_attachment.attached_to).to eq(proposal)
        end

        context "when attachments are allowed and file is invalid" do
          let(:uploaded_files) do
            [
              { file: upload_test_file(Decidim::Dev.test_file("city.jpeg", "image/jpeg")) },
              { file: upload_test_file(Decidim::Dev.test_file("verify_user_groups.csv", "text/csv")) }
            ]
          end

          it "does not create atachments for the proposal" do
            expect { command.call }.not_to change(Decidim::Attachment, :count)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
