# frozen_string_literal: true

require "spec_helper"
require "decidim/accountability/test/factories"
require "decidim/meetings/test/factories"
require "decidim/budgets/test/factories"
require "decidim/elections/test/factories"
require "decidim/proposals/test/capybara_proposals_picker"

describe "Admin find_resource_manifest", type: :system do
  let(:organization) { create :organization }
  let(:participatory_process) { create :participatory_process, organization: organization }
  let(:proposal_component) { create :proposal_component, participatory_space: participatory_process }
  let!(:proposal) { create(:proposal, title: { en: "proposal" }, component: proposal_component) }
  let(:reporting_component) { create :reporting_proposals_component, participatory_space: participatory_process }
  let!(:reporting_proposal) { create(:proposal, title: { en: "reporting_proposal" }, component: reporting_component) }
  let(:user) { create(:user, :confirmed, :admin, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  describe "accountability" do
    let(:component) { create :accountability_component, participatory_space: participatory_process }
    let!(:result) { create(:result, component: component) }

    it "admin can choose reporting proposals on creating" do
      visit manage_component_path(component)
      within ".button--title" do
        click_link "New Result"
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

        proposals_pick(select_data_picker(:result_proposals, multiple: true), [proposal, reporting_proposal])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      within find("tr", text: "My result") do
        click_link "Edit"
      end
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_content(translated(reporting_proposal.title))
    end

    it "admin can choose reporting proposals" do
      visit manage_component_path(component)
      click_link "Edit"
      within ".edit_result" do
        proposals_pick(select_data_picker(:result_proposals, multiple: true), [proposal, reporting_proposal])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      click_link "Edit"
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_content(translated(reporting_proposal.title))
    end

    it "admin can choose normal proposals" do
      visit manage_component_path(component)
      click_link "Edit"
      within ".edit_result" do
        proposals_pick(select_data_picker(:result_proposals, multiple: true), [proposal])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      click_link "Edit"
      expect(page).to have_content(translated(proposal.title))
      expect(page).not_to have_content(translated(reporting_proposal.title))
    end
  end

  describe "budgets" do
    let(:component) { create :budgets_component, participatory_space: participatory_process }
    let!(:project) { create(:project, component: component) }

    it "admin can choose reporting proposals when creating" do
      visit manage_component_path(component)
      click_link "Manage projects"
      click_link "New Project"

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
        proposals_pick(select_data_picker(:project_proposals, multiple: true), [proposal, reporting_proposal])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within find("tr", text: "My project") do
        click_link "Edit"
      end
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_content(translated(reporting_proposal.title))
    end

    it "admin can choose reporting proposals" do
      visit manage_component_path(component)
      click_link "Manage projects"
      click_link "Edit"
      within ".edit_project" do
        proposals_pick(select_data_picker(:project_proposals, multiple: true), [proposal, reporting_proposal])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      click_link "Edit"
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_content(translated(reporting_proposal.title))
    end

    it "admin can choose normal proposals" do
      visit manage_component_path(component)
      click_link "Manage projects"
      click_link "Edit"
      within ".edit_project" do
        proposals_pick(select_data_picker(:project_proposals, multiple: true), [proposal])
        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      click_link "Edit"
      expect(page).to have_content(translated(proposal.title))
      expect(page).not_to have_content(translated(reporting_proposal.title))
    end
  end

  describe "meetings" do
    let(:component) { create :meeting_component, :with_creation_enabled, participatory_space: participatory_process }
    let!(:meeting) { create(:meeting, :past, component: component, author: user) }

    it "user can choose reporting_proposals" do
      visit main_component_path(component)

      click_link translated(meeting.title)
      click_link "Close meeting"

      expect(page).to have_content "CLOSE MEETING"
      within "form.edit_close_meeting" do
        expect(page).to have_content "Choose proposals"

        fill_in :close_meeting_closing_report, with: "Very nice meeting"
        fill_in :close_meeting_attendees_count, with: 10

        proposals_pick(select_data_picker(:close_meeting_proposals, multiple: true), [proposal, reporting_proposal])

        click_button "Close meeting"
      end
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_content(translated(reporting_proposal.title))
    end

    it "user can choose normal proposals" do
      visit main_component_path(component)

      click_link translated(meeting.title)
      click_link "Close meeting"

      expect(page).to have_content "CLOSE MEETING"
      within "form.edit_close_meeting" do
        expect(page).to have_content "Choose proposals"

        fill_in :close_meeting_closing_report, with: "Very nice meeting"
        fill_in :close_meeting_attendees_count, with: 10

        proposals_pick(select_data_picker(:close_meeting_proposals, multiple: true), [proposal])

        click_button "Close meeting"
      end
      expect(page).to have_content(translated(proposal.title))
      expect(page).not_to have_content(translated(reporting_proposal.title))
    end

    context "when admin" do
      let!(:meeting) { create(:meeting, :past, component: component) }

      it "admin can choose reporting proposals" do
        visit manage_component_path(component)
        page.click_link "Close"

        within ".edit_close_meeting" do
          expect(page).to have_content "Choose proposals"

          fill_in_i18n_editor(
            :close_meeting_closing_report,
            "#close_meeting-closing_report-tabs",
            en: "The meeting was great!"
          )
          fill_in :close_meeting_attendees_count, with: 12
          proposals_pick(select_data_picker(:close_meeting_proposals, multiple: true), [proposal, reporting_proposal])
          click_button "Close"
        end

        expect(page).to have_admin_callout("Meeting successfully closed")
        expect(page).to have_content("Yes")

        page.click_link "Close"
        expect(page).to have_content(translated(proposal.title))
        expect(page).to have_content(translated(reporting_proposal.title))
      end

      it "admin can choose normal proposals" do
        visit manage_component_path(component)
        page.click_link "Close"

        within ".edit_close_meeting" do
          expect(page).to have_content "Choose proposals"

          fill_in_i18n_editor(
            :close_meeting_closing_report,
            "#close_meeting-closing_report-tabs",
            en: "The meeting was great!"
          )
          fill_in :close_meeting_attendees_count, with: 12
          proposals_pick(select_data_picker(:close_meeting_proposals, multiple: true), [proposal])
          click_button "Close"
        end

        expect(page).to have_admin_callout("Meeting successfully closed")
        expect(page).to have_content("Yes")

        page.click_link "Close"
        expect(page).to have_content(translated(proposal.title))
        expect(page).not_to have_content(translated(reporting_proposal.title))
      end
    end
  end

  describe "elections" do
    let(:component) { create :elections_component, participatory_space: participatory_process }
    let(:election) { create(:election, component: component) }
    let(:question) { create(:question, election: election) }
    let!(:answer) { create(:election_answer, question: question) }

    it "admin can choose reporting proposals" do
      visit manage_component_path(component)
      click_link "Manage questions"
      click_link "Manage answers"
      click_link "Edit"

      within ".edit_answer" do
        expect(page).to have_content "Choose proposals"

        fill_in_i18n(
          :answer_title,
          "#answer-title-tabs",
          en: "A Question"
        )
        proposals_pick(select_data_picker(:answer_proposals, multiple: true), [proposal, reporting_proposal])
        click_button "Update answer"
      end

      expect(page).to have_admin_callout("Answer successfully updated")

      page.click_link "Edit"
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_content(translated(reporting_proposal.title))
    end

    it "admin can choose reporting proposals on create" do
      visit manage_component_path(component)
      click_link "Manage questions"
      click_link "Manage answers"
      click_link "New Answer"

      within ".new_answer" do
        expect(page).to have_content "Choose proposals"

        fill_in_i18n(
          :answer_title,
          "#answer-title-tabs",
          en: "A Question"
        )
        proposals_pick(select_data_picker(:answer_proposals, multiple: true), [proposal, reporting_proposal])
        click_button "Create answer"
      end

      expect(page).to have_admin_callout("Answer successfully created")

      within find("tr", text: "A Question") do
        page.click_link "Edit"
      end
      expect(page).to have_content(translated(proposal.title))
      expect(page).to have_content(translated(reporting_proposal.title))
    end
  end
end
