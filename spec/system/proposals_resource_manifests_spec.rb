# frozen_string_literal: true

require "spec_helper"
require "decidim/accountability/test/factories"
require "decidim/meetings/test/factories"
require "decidim/budgets/test/factories"

describe "Admin find_resource_manifest" do # rubocop:disable RSpec/DescribeClass
  let(:organization) { create(:organization) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:proposal_component) { create(:proposal_component, participatory_space: participatory_process) }
  let!(:proposal) { create(:proposal, title: { en: "A proposal" }, component: proposal_component) }
  let(:reporting_component) { create(:reporting_proposals_component, participatory_space: participatory_process) }
  let!(:reporting_proposal) { create(:proposal, title: { en: "A reporting proposal" }, component: reporting_component) }
  let(:user) { create(:user, :confirmed, :admin, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "accountability" do
    let(:component) { create(:accountability_component, participatory_space: participatory_process) }
    let!(:result) { create(:result, component:) }

    it "admin can choose reporting proposals on creating" do
      visit manage_component_path(component)
      within ".item_show__header" do
        click_on "New result"
      end
      within ".new_result" do
        fill_in_i18n(
          :result_title,
          "#result-title-tabs",
          en: "My result"
        )
        fill_in_i18n_editor(
          :result_description,
          "#result-description-tabs",
          en: "A longer description"
        )

        tom_select("#proposals_list", option_id: [proposal.id, reporting_proposal.id])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      within "tr", text: "My result" do
        click_on "Edit"
      end
      within ".plugin-dropdown_input" do
        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_content(translated(reporting_proposal.title))
      end
    end

    it "admin can choose reporting proposals" do
      visit manage_component_path(component)
      click_on "Edit"
      within ".edit_result" do
        tom_select("#proposals_list", option_id: [proposal.id, reporting_proposal.id])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      click_on "Edit"
      within ".plugin-dropdown_input" do
        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_content(translated(reporting_proposal.title))
      end
    end

    it "admin can choose normal proposals" do
      visit manage_component_path(component)
      click_on "Edit"
      within ".edit_result" do
        tom_select("#proposals_list", option_id: [proposal.id])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      click_on "Edit"
      within ".plugin-dropdown_input" do
        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_no_content(translated(reporting_proposal.title))
      end
    end
  end

  describe "budgets" do
    let(:component) { create(:budgets_component, participatory_space: participatory_process) }
    let!(:project) { create(:project, component:) }

    it "admin can choose reporting proposals when creating" do
      visit manage_component_path(component)
      click_on "Manage projects"
      click_on "New project"

      within ".new_project" do
        fill_in_i18n(
          :project_title,
          "#project-title-tabs",
          en: "My project"
        )
        fill_in_i18n_editor(
          :project_description,
          "#project-description-tabs",
          en: "A longer description"
        )
        fill_in :project_budget_amount, with: 22_000_000
        tom_select("#proposals_list", option_id: [proposal.id, reporting_proposal.id])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "tr", text: "My project" do
        click_on "Edit"
      end
      within ".plugin-dropdown_input" do
        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_content(translated(reporting_proposal.title))
      end
    end

    it "admin can choose reporting proposals" do
      visit manage_component_path(component)
      click_on "Manage projects"
      click_on "Edit"
      within ".edit_project" do
        tom_select("#proposals_list", option_id: [proposal.id, reporting_proposal.id])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      click_on "Edit"
      within ".plugin-dropdown_input" do
        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_content(translated(reporting_proposal.title))
      end
    end

    it "admin can choose normal proposals" do
      visit manage_component_path(component)
      click_on "Manage projects"
      click_on "Edit"
      within ".edit_project" do
        tom_select("#proposals_list", option_id: [proposal.id])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      click_on "Edit"
      within ".plugin-dropdown_input" do
        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_no_content(translated(reporting_proposal.title))
      end
    end
  end

  describe "meetings" do
    let(:component) { create(:meeting_component, :with_creation_enabled, participatory_space: participatory_process) }
    let!(:meeting) { create(:meeting, :past, :published, component:, author: user) }

    it "user can choose reporting_proposals" do
      visit main_component_path(component)

      click_on translated(meeting.title)
      click_on "Close meeting"

      expect(page).to have_content "Close meeting"
      within "form.edit_close_meeting" do
        expect(page).to have_content "Proposals"

        fill_in :close_meeting_closing_report, with: "Very nice meeting"
        fill_in :close_meeting_attendees_count, with: 10

        tom_select("#proposals_list", option_id: [proposal.id, reporting_proposal.id])

        click_on "Close meeting"
      end
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_content(translated(reporting_proposal.title))
    end

    it "user can choose normal proposals" do
      visit main_component_path(component)

      click_on translated(meeting.title)
      click_on "Close meeting"

      expect(page).to have_content "Close meeting"
      within "form.edit_close_meeting" do
        expect(page).to have_content "Proposals"

        fill_in :close_meeting_closing_report, with: "Very nice meeting"
        fill_in :close_meeting_attendees_count, with: 10

        tom_select("#proposals_list", option_id: [proposal.id])

        click_on "Close meeting"
      end
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_no_content(translated(reporting_proposal.title))
    end

    context "when admin" do
      let!(:meeting) { create(:meeting, :past, :published, component:) }

      it "admin can choose reporting proposals" do
        visit manage_component_path(component)
        page.click_on "Close"

        within ".edit_close_meeting" do
          expect(page).to have_content "Proposals"

          fill_in_i18n_editor(
            :close_meeting_closing_report,
            "#close_meeting-closing_report-tabs",
            en: "The meeting was great!"
          )
          fill_in :close_meeting_attendees_count, with: 12
          tom_select("#proposals_list", option_id: [proposal.id, reporting_proposal.id])
          click_on "Close"
        end

        expect(page).to have_admin_callout("Meeting successfully closed")
        expect(page).to have_content("Yes")

        page.click_on "Close"
        within ".plugin-dropdown_input" do
          expect(page).to have_content(translated(proposal.title))
          expect(page).to have_content(translated(reporting_proposal.title))
        end
      end

      it "admin can choose normal proposals" do
        visit manage_component_path(component)
        page.click_on "Close"

        within ".edit_close_meeting" do
          expect(page).to have_content "Proposals"

          fill_in_i18n_editor(
            :close_meeting_closing_report,
            "#close_meeting-closing_report-tabs",
            en: "The meeting was great!"
          )
          fill_in :close_meeting_attendees_count, with: 12
          tom_select("#proposals_list", option_id: [proposal.id])
          click_on "Close"
        end

        expect(page).to have_admin_callout("Meeting successfully closed")
        expect(page).to have_content("Yes")

        page.click_on "Close"
        within ".plugin-dropdown_input" do
          expect(page).to have_content(translated(proposal.title))
          expect(page).to have_no_content(translated(reporting_proposal.title))
        end
      end
    end
  end
end
