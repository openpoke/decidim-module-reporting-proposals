# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/lib/decidim/component_validator.rb" => "0a15717077cb8e71bf5b6cfea72f98b2",
      "/lib/decidim/map/autocomplete.rb" => "1dab14e93feda12f3e8e22648f6d9ef1",
      "/lib/decidim/form_builder.rb" => "ebb2cad7d2c6e15cb6434ae94844053e",
      "/app/models/decidim/participatory_space_role_config/evaluator.rb" => "5cc6b7a73ed86b9ea5e0485e48059204",
      "/app/mailers/decidim/reported_mailer.rb" => "46d6aed40d3bdfcd8abd71ffff1bc203",
      "/app/views/decidim/reported_mailer/report.html.erb" => "467e184b012a1e9d0f47035b5bb5f9f1",
      "/app/presenters/decidim/resource_locator_presenter.rb" => "f42e6aaa9cec25bcd9d60f139aa4eb9c",
      "/app/cells/decidim/linked_resources_for_cell.rb" => "7559a251620f5ca336c175a8d8ceabdc"
    }
  },
  {
    package: "decidim-templates",
    files: {
      "/app/commands/decidim/templates/admin/create_proposal_answer_template.rb" => "7561c04a90b8451cb4afa7ec0a91d50b",
      "/app/commands/decidim/templates/admin/update_proposal_answer_template.rb" => "f64ef0f68517b1a2c5fe06c56cf48f0c",
      "/app/controllers/decidim/templates/admin/proposal_answer_templates_controller.rb" => "37096924f2b1e9ed336e7e4cde03c251"
    }
  },
  {
    package: "decidim-proposals",
    files: {
      # the reporting_proposals manifest mirrors this one
      "/lib/decidim/proposals/component.rb" => "94eaf5edbe5eb3221cdb911725af3660",
      "/app/events/decidim/proposals/publish_proposal_event.rb" => "085ba02d02310d94b462b43c973007c6",
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "5f0946cb500e390a4a8f02857fbe9646",
      "/app/controllers/decidim/proposals/admin/proposals_controller.rb" => "47dc8a8344f68eac1c60dec3d1010484",
      "/app/helpers/decidim/proposals/proposal_wizard_helper.rb" => "330889e7edb2fbd3571391a32d3d02c8",
      "/app/helpers/decidim/proposals/admin/proposal_bulk_actions_helper.rb" => "3fd940649b18f5dc5659e4ccb3dd97dd",
      "/app/helpers/decidim/proposals/admin/proposals_helper.rb" => "7cfdb8ae8d95e85f64c844bd00f6ba5b",
      "/app/commands/decidim/proposals/create_proposal.rb" => "3d7cfe8f5d1eea00594ce29c4b37985b",
      "/app/commands/decidim/proposals/update_proposal.rb" => "0a908738027f7149f7aebf34a43c0530",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "e09c81d15493760f736d6b2020bae98c",
      "/app/forms/decidim/proposals/proposal_form.rb" => "fb1b26c23bf3d0dbe59ad02509e6445a",
      "/app/views/decidim/proposals/proposals/preview.html.erb" => "b9c6a7d417a5fa18bc96dea846a581ed",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "ba8c88bdf07061fda1962c54868c9131",
      "/app/views/decidim/proposals/proposals/edit.html.erb" => "6d34fd034334d83c60632cf478530d98",
      "/app/views/decidim/proposals/proposals/index.html.erb" => "e3733b41a9bb2feca2faa1c0ef725ee3",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "3e51c7a14d250a1abef0753a1db7661b",
      "/app/views/decidim/proposals/admin/proposals/_proposal-tr.html.erb" => "608af89f7bfa800fe2e3c853f8e2ace0",
      "/app/views/decidim/proposals/admin/proposals/_proposals-thead.html.erb" => "24c74e018ea4ac719652dd4c5acd4a29",
      "/app/views/decidim/proposals/admin/proposals/_actions.html.erb" => "d6e35588d5b68c73d92cb43aa537b93e",
      "/app/views/decidim/proposals/admin/proposals/index.html.erb" => "fe8896195253c1224f362df321880c02",
      "/app/views/decidim/proposals/admin/proposals/show.html.erb" => "d66a83af72f94224299d035cf19036cd",
      "/app/commands/decidim/proposals/admin/assign_proposals_to_evaluator.rb" => "2ecd84c44310df9e6797fd1af8ff39ce",
      "/app/permissions/decidim/proposals/admin/permissions.rb" => "47869294893fca27a70a3d7aee3fd2d1",
      "/app/controllers/decidim/proposals/admin/proposal_answers_controller.rb" => "84aaa6d5fa595a87b77de10b0103a958",
      "/app/controllers/decidim/proposals/admin/evaluation_assignments_controller.rb" => "1288c226452e8409ef93e89fe76c47f7",
      "/app/views/decidim/proposals/proposals/show.html.erb" => "54c1771d6aa2563e15d5fb688a721378",
      "/app/views/decidim/proposals/proposals/_wizard_header.html.erb" => "60700214b35bbca30979a1ca4d0b0bb6",
      "/app/views/decidim/proposals/admin/proposal_notes/_proposal_note.html.erb" => "b0b9b94fd5b643b67608d76181c5704d",
      "/app/cells/decidim/proposals/proposals_picker_cell.rb" => "cf40967e6846216ed73f7eaa1ae3d09e",
      "/app/queries/decidim/proposals/filtered_proposals.rb" => "15a88d796449df46426d36354894a346"
    }
  },
  {
    package: "decidim-accountability",
    files: {
      "/app/forms/decidim/accountability/admin/result_form.rb" => "5514ab52d225bcb70dee33f4ab360a4f",
      "/app/commands/decidim/accountability/admin/create_result.rb" => "1bb7534070b15208cb27d75ee69cd84f",
      "/app/commands/decidim/accountability/admin/update_result.rb" => "ca437fa0af7d3ddf05685f23ee008339"
    }
  },
  {
    package: "decidim-budgets",
    files: {
      "/app/forms/decidim/budgets/admin/project_form.rb" => "3283f713207e41bf33266329eab38ac6"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/forms/decidim/meetings/admin/close_meeting_form.rb" => "de3f7cce87a91154e05122c2b44db045",
      "/app/forms/decidim/meetings/close_meeting_form.rb" => "9ccf72f8fa7d10e107e4561c033a7a63",
      "/app/commands/decidim/meetings/admin/close_meeting.rb" => "166f868e741d8c7613185e5bffc2132c"
    }
  },
  {
    package: "decidim-participatory_processes",
    files: {
      "/app/permissions/decidim/participatory_processes/permissions.rb" => "0b84c4fa9242b16abee44f584fd97ff5"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      "/app/permissions/decidim/assemblies/permissions.rb" => "5a864f5d485c4b8c2c0859ae38e88e16"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    item[:files].each do |file, signature|
      it "#{item[:package]}#{file} matches checksum" do
        expect(md5("#{Gem::Specification.find_by_name(item[:package]).gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
