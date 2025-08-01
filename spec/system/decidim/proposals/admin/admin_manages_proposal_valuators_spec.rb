# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals valuators" do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, component: current_component) }
  let!(:reportables) { create_list(:proposal, 3, component: current_component) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end
  let!(:valuator) { create(:user, organization:) }
  let!(:valuator_role) { create(:participatory_process_user_role, role: :valuator, user: valuator, participatory_process:) }
  let(:second_valuator) { create(:user, organization:) }
  let(:second_valuator_role) { create(:participatory_process_user_role, role: :valuator, user: second_valuator, participatory_process:) }
  let!(:admin) { create(:user, :admin, organization:) }

  include Decidim::ComponentPathHelper

  include_context "when managing a component as an admin"

  context "when assigning to a valuator" do
    before do
      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Assign to valuator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-assign-proposals-to-valuator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_button("Assign", count: 1)
    end

    context "when submitting the form" do
      before do
        perform_enqueued_jobs do
          within "#js-form-assign-proposals-to-valuator" do
            tom_select("#assign_valuator_role_ids", option_id: valuator_role.id)
            click_on("Assign")
          end
        end
      end

      it "assigns the proposals to the valuator" do
        expect(page).to have_content("Proposals assigned to a valuator successfully")

        within "tr", text: translated(proposal.title) do
          expect(page).to have_css("td.valuators-count", text: valuator.name)
        end
      end

      it "sends notification with email" do
        expect(last_email.subject).to include("New proposals assigned to you for evaluation")
        expect(last_email.from).to eq([Decidim::Organization.first.smtp_settings["from"]])
        expect(last_email.to).to eq([valuator.email])
        expect(last_email.body.encoded).to include("You've been assigned as a valuator")
        expect(last_email.body.encoded).to include(Decidim::ResourceLocatorPresenter.new(proposal).admin_url)
      end

      context "when a valuator already exists" do
        before do
          create(:valuation_assignment, proposal:, valuator_role: second_valuator_role)

          visit current_path
        end

        it "assigns the proposals to the valuator" do
          within "tr", text: translated(proposal.title) do
            expect(page).to have_css("td.valuators-count", text: "#{valuator.name} (+1)")
          end
        end
      end
    end
  end

  context "when filtering proposals by assigned valuator" do
    let!(:unassigned_proposal) { create(:proposal, component:) }
    let(:assigned_proposal) { proposal }

    before do
      create(:valuation_assignment, proposal:, valuator_role:)

      visit current_path
    end

    it "only shows the proposals assigned to the selected valuator" do
      expect(page).to have_content(translated(assigned_proposal.title))
      expect(page).to have_content(translated(unassigned_proposal.title))

      within ".filters__section" do
        find("a.dropdown", text: "Filter").hover
        find("a", text: "Assigned to valuator").hover
        find("a", text: valuator.name).click
      end

      expect(page).to have_content(translated(assigned_proposal.title))
      expect(page).to have_no_content(translated(unassigned_proposal.title))
    end
  end

  context "when unassigning valuators from a proposal from the proposals index page" do
    let(:assigned_proposal) { proposal }

    before do
      create(:valuation_assignment, proposal:, valuator_role:)

      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Unassign from valuator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-unassign-proposals-from-valuator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_button("Unassign", count: 1)
    end

    context "when submitting the form" do
      before do
        within "#js-form-unassign-proposals-from-valuator" do
          tom_select("#unassign_valuator_role_ids", option_id: valuator_role.id)
          click_on("Unassign")
        end
      end

      it "unassigns the proposals to the valuator" do
        expect(page).to have_content("Valuator unassigned from proposals successfully")

        within "tr", text: translated(proposal.title) do
          expect(page).to have_css("td.valuators-count", text: 0)
        end
      end
    end
  end

  context "when unassigning valuators from a proposal from the proposal show page" do
    let(:assigned_proposal) { proposal }

    before do
      create(:valuation_assignment, proposal:, valuator_role:)

      visit current_path

      find("a", text: translated(proposal.title)).click
    end

    it "can unassign a valuator" do
      within "#valuators" do
        expect(page).to have_content(valuator.name)

        accept_confirm do
          find("a.red-icon").click
        end
      end

      expect(page).to have_content("Valuator unassigned from proposals successfully")

      within "#valuators" do
        expect(page).to have_no_css("a.red-icon")
      end
    end
  end

  context "when assigning valuators to proposal from the proposal show page" do
    let(:unassigned_proposal) { proposal }

    before do
      visit current_path

      find("a", text: translated(proposal.title)).click
    end

    it "stay in the same url and add valuator user to list after assignment evaluator" do
      within "#js-form-assign-proposal-to-valuator" do
        select valuator.name, from: :assign_valuator_role_ids
      end

      click_on "Assign"

      expect(current_url).to end_with(current_path)
      expect(page).to have_css(".red-icon")
      expect(page).to have_content(valuator.name)
    end
  end
end
