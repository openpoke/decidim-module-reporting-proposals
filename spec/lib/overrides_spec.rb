# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/lib/decidim/component_validator.rb" => "f2d90649846a7a5b834d4e46b006d0d9",
      "/lib/decidim/map/autocomplete.rb" => "5ab8ec8069bcc5c367a057919b08d05d",
      "/lib/decidim/form_builder.rb" => "809c35c6f027f0e6dfb4a698899fe07c",
      "/app/helpers/decidim/resource_helper.rb" => "f170d522302a5c6efb1380e1eb4ca8d4",
      "/app/commands/decidim/create_report.rb" => "a355b1f7e44cfbc0b8ae4726a71e3eee",
      "/app/commands/decidim/gallery_methods.rb" => "9a33f44912059c9764691abb03f70a84",
      "/app/models/decidim/category.rb" => "fc044f23d00373d62693ee7f044558fe",
      "/app/models/decidim/participatory_space_role_config/valuator.rb" => "8dbcc7c787a7db6e9cdebccf888ffbdf",
      "/app/mailers/decidim/reported_mailer.rb" => "4a902dfb5d444f48518166bdad808151",
      "/app/presenters/decidim/resource_locator_presenter.rb" => "84a195ea879885bd7fa78dfa51ee7f12",
      "/app/cells/decidim/linked_resources_for_cell.rb" => "960a6d404ba9e9f4a3b3d9160193ea5c"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/forms/decidim/admin/category_form.rb" => "cb56a20226a48af9cebca68d3c612d6b",
      "/app/commands/decidim/admin/create_category.rb" => "fdbe8b71ebe724f8bc97ef8c5c862ad0",
      "/app/commands/decidim/admin/update_category.rb" => "c3d8a49dd6a9d7c51f9e9d0c6c4b5cb1",
      "/app/controllers/decidim/admin/categories_controller.rb" => "5030981cb309d05a8fe41c220367986b",
      "/app/views/decidim/admin/categories/index.html.erb" => "a37f7bee7121fdbc309e3f748cf80a5c",
      "/app/views/decidim/admin/categories/_form.html.erb" => "fbdcbd4745300402700b2ff386d7f56d"
    }
  },
  {
    package: "decidim-templates",
    files: {
      "/app/commands/decidim/templates/admin/update_proposal_answer_template.rb" => "7489983b43b347e9923f9e2b1b0e96c3",
      "/app/controllers/decidim/templates/admin/proposal_answer_templates_controller.rb" => "fd1f569220ce38e82e5bb4a39c8146ff"
    }
  },
  {
    package: "decidim-proposals",
    files: {
      "/lib/decidim/proposals/component.rb" => "2c66361882b7f8f4c06b2a3343688dfa",
      "/app/events/decidim/proposals/publish_proposal_event.rb" => "085ba02d02310d94b462b43c973007c6",
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "5ec87417fc0231203fc39b02ebab82f0",
      "/app/helpers/decidim/proposals/proposal_wizard_helper.rb" => "8b607684f294c6f1824ba6bc3390577e",
      "/app/commands/decidim/proposals/create_proposal.rb" => "95c7bba44dbe477abdfbf450b7eee258",
      "/app/commands/decidim/proposals/update_proposal.rb" => "1cc15b946512f4d5a54d1cf5aea8450a",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "30c6c7e5504394e0a69a9776cc319b57",
      "/app/commands/decidim/proposals/admin/answer_proposal.rb" => "f69543d7c76f94673307cedc760e07a4",
      "/app/forms/decidim/proposals/proposal_form.rb" => "476f231cc6c40862e630bcb820ee22fc",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "da9b07a9fb0c06f92690f959fb63dd15",
      "/app/views/decidim/proposals/proposals/edit.html.erb" => "6d34fd034334d83c60632cf478530d98",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "3e51c7a14d250a1abef0753a1db7661b",
      "/app/views/decidim/proposals/proposals/_edit_form_fields.html.erb" => "436675509c9efcac91a0a99f062731f5",
      "/app/views/decidim/proposals/admin/proposals/_proposal-tr.html.erb" => "40e55fc65ac379c520b674cf9875b9c9",
      "/app/views/decidim/proposals/admin/proposals/show.html.erb" => "097fef7eed53d8e21a0032d84ae3790a",
      "/app/commands/decidim/proposals/admin/assign_proposals_to_valuator.rb" => "aa551badfe5a9e07ca78f6a221f941e8",
      "/app/permissions/decidim/proposals/admin/permissions.rb" => "0953317e3504b1aa741d3fb20f1743cc",
      "/app/controllers/decidim/proposals/admin/proposal_answers_controller.rb" => "1a68a15c6589552dad41151a916f7fd1",
      "/app/controllers/decidim/proposals/admin/valuation_assignments_controller.rb" => "c558d21a69ea1c9c9e7d70fdc8f7d20e",
      "/app/views/decidim/proposals/proposals/show.html.erb" => "1c43824df4e84de47111e86d3193efd1",
      "/app/views/decidim/proposals/proposals/_wizard_header.html.erb" => "170dd2d5e221278c83f76d64abbb8e9c",
      "/app/views/decidim/proposals/admin/proposal_notes/_proposal_notes.html.erb" => "8d7496ad8ce70d68daea46f7ea91f2df",
      "/app/cells/decidim/proposals/proposals_picker_cell.rb" => "cf40967e6846216ed73f7eaa1ae3d09e"
    }
  },
  {
    package: "decidim-accountability",
    files: {
      "/app/forms/decidim/accountability/admin/result_form.rb" => "8bb1bd9535cbc33ad5f75227009247d9",
      "/app/commands/decidim/accountability/admin/create_result.rb" => "cf29e89997407c150481ad185b6b5b82",
      "/app/commands/decidim/accountability/admin/update_result.rb" => "f7edc5a92b8ff8cf0ddf6176f23615b4"
    }
  },
  {
    package: "decidim-budgets",
    files: {
      "/app/forms/decidim/budgets/admin/project_form.rb" => "ff35fa4d56437f1461487c32aad9ce5e"
    }
  },
  {
    package: "decidim-elections",
    files: {
      "/app/forms/decidim/elections/admin/answer_form.rb" => "98f398a4ff58e2464e199efc21b14ddd"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/forms/decidim/meetings/admin/close_meeting_form.rb" => "39d63699796109c2163e89f88218dc08",
      "/app/forms/decidim/meetings/close_meeting_form.rb" => "f532c2ddd7205dd9a1351552303b8f43",
      "/app/commands/decidim/meetings/admin/close_meeting.rb" => "166f868e741d8c7613185e5bffc2132c"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
