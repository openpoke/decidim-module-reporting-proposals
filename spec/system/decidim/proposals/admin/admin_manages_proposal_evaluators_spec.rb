# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals evaluators" do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create(:proposal, component: current_component) }
  let!(:reportables) { create_list(:proposal, 3, component: current_component) }
  let(:participatory_process) { create(:participatory_process, :with_steps, organization:) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end
  let!(:evaluator) { create(:user, organization:) }
  let!(:evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: evaluator, participatory_process:) }
  let(:second_evaluator) { create(:user, organization:) }
  let(:second_evaluator_role) { create(:participatory_process_user_role, role: :evaluator, user: second_evaluator, participatory_process:) }
  let!(:admin) { create(:user, :admin, organization:) }

  include Decidim::ComponentPathHelper

  include_context "when managing a component as an admin"

  context "when assigning to an evaluator" do
    before do
      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Assign to evaluator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-assign-proposals-to-evaluator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_button("Assign", count: 1)
    end

    context "when submitting the form" do
      before do
        perform_enqueued_jobs do
          within "#js-form-assign-proposals-to-evaluator" do
            tom_select("#assign_evaluator_role_ids", option_id: evaluator_role.id)
            click_on("Assign")
          end
        end
      end

      it "assigns the proposals to the evaluator" do
        expect(page).to have_content("Proposals assigned to a evaluator successfully")

        within "tr", text: translated(proposal.title) do
          expect(page).to have_css("td.evaluators-count", text: evaluator.name)
        end
      end

      context "when an evaluator already exists" do
        before do
          create(:evaluation_assignment, proposal:, evaluator_role: second_evaluator_role)

          visit current_path
        end

        it "assigns the proposals to the evaluator" do
          within "tr", text: translated(proposal.title) do
            expect(page).to have_css("td.evaluators-count") do |element|
              expect(element.text).to match(/#{evaluator.name}|#{second_evaluator.name}/)
            end
            expect(page).to have_css("td.evaluators-count", text: "(+1)")
          end
        end
      end
    end
  end

  context "when filtering proposals by assigned evaluator" do
    let!(:unassigned_proposal) { create(:proposal, component:) }
    let(:assigned_proposal) { proposal }

    before do
      create(:evaluation_assignment, proposal:, evaluator_role:)

      visit current_path
    end

    it "only shows the proposals assigned to the selected evaluator" do
      expect(page).to have_content(translated(assigned_proposal.title))
      expect(page).to have_content(translated(unassigned_proposal.title))

      within ".filters__section" do
        click_on "Filter"
        find("a", text: "Assigned to evaluator").click
        find("a", text: evaluator.name).click
      end

      expect(page).to have_content(translated(assigned_proposal.title))
      expect(page).to have_no_content(translated(unassigned_proposal.title))
    end
  end

  context "when unassigning evaluators from a proposal from the proposals index page" do
    let(:assigned_proposal) { proposal }

    before do
      create(:evaluation_assignment, proposal:, evaluator_role:)

      visit current_path

      within "tr", text: translated(proposal.title) do
        page.first(".js-proposal-list-check").set(true)
      end

      click_on "Actions"
      click_on "Unassign from evaluator"
    end

    it "shows the component select" do
      expect(page).to have_css("#js-form-unassign-proposals-from-evaluator select", count: 1)
    end

    it "shows an update button" do
      expect(page).to have_button("Unassign", count: 1)
    end

    context "when submitting the form" do
      before do
        within "#js-form-unassign-proposals-from-evaluator" do
          tom_select("#unassign_evaluator_role_ids", option_id: evaluator_role.id)
          click_on("Unassign")
        end
      end

      it "unassigns the proposals to the evaluator" do
        expect(page).to have_content("Evaluator unassigned from proposals successfully")

        within "tr", text: translated(proposal.title) do
          expect(page).to have_css("td.evaluators-count", text: 0)
        end
      end
    end
  end

  context "when unassigning evaluators from a proposal from the proposal show page" do
    let(:assigned_proposal) { proposal }

    before do
      create(:evaluation_assignment, proposal:, evaluator_role:)

      visit current_path

      within "tr", text: translated(proposal.title) do
        find("button[data-controller='dropdown']").click
        click_on "Answer proposal"
      end
    end

    it "can unassign a evaluator" do
      within "#evaluators" do
        expect(page).to have_content(evaluator.name)

        accept_confirm do
          find("a.red-icon").click
        end
      end

      expect(page).to have_content("Evaluator unassigned from proposals successfully")

      within "#evaluators" do
        expect(page).to have_no_css("a.red-icon")
      end
    end
  end

  context "when assigning evaluators to proposal from the proposal show page" do
    let(:unassigned_proposal) { proposal }

    before do
      visit current_path

      within "tr", text: translated(proposal.title) do
        find("button[data-controller='dropdown']").click
        click_on "Answer proposal"
      end
    end

    it "stay in the same url and add valuator user to list after assignment evaluator" do
      within "#js-form-assign-proposal-to-evaluator" do
        select evaluator.name, from: :assign_evaluator_role_ids
      end

      click_on "Assign"

      expect(current_url).to end_with(current_path)
      expect(page).to have_css("a.red-icon")
      expect(page).to have_content(evaluator.name)
    end
  end
end
