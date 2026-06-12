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
      "/lib/decidim/map/autocomplete.rb" => "82be06c3cc65e5e6715c8cbeea92e2fd",
      "/lib/decidim/form_builder.rb" => "979bc8801b13cfd100c5b9edf2166c38",
      "/lib/decidim/resource_helper.rb" => "6e5c33c68581bbfabcf5bdd489d65a25",
      "/app/commands/decidim/gallery_methods.rb" => "9a33f44912059c9764691abb03f70a84",
      "/app/models/decidim/participatory_space_role_config/evaluator.rb" => "5cc6b7a73ed86b9ea5e0485e48059204",
      "/app/mailers/decidim/reported_mailer.rb" => "71d62556c29e7edb52cf09ad4da28cf1",
      "/app/presenters/decidim/resource_locator_presenter.rb" => "deda86158a3c82690f1a2656465fae18",
      "/app/cells/decidim/linked_resources_for_cell.rb" => "7559a251620f5ca336c175a8d8ceabdc"
    }
  },
  {
    package: "decidim-templates",
    files: {
      "/app/commands/decidim/templates/admin/update_proposal_answer_template.rb" => "9ee3f25f047e17a5b7041d43ba319183",
      "/app/controllers/decidim/templates/admin/proposal_answer_templates_controller.rb" => "de223364a9061aa42c127a6493d1a731"
    }
  },
  {
    package: "decidim-proposals",
    files: {
      "/app/events/decidim/proposals/publish_proposal_event.rb" => "085ba02d02310d94b462b43c973007c6",
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "92bf9b32eb4968b6ad71c1711e4750d2",
      "/app/helpers/decidim/proposals/proposal_wizard_helper.rb" => "330889e7edb2fbd3571391a32d3d02c8",
      "/app/commands/decidim/proposals/create_proposal.rb" => "f4f306b35fc646a843f2adb5da13f2fc",
      "/app/commands/decidim/proposals/update_proposal.rb" => "4faca87c1bc95f5e7d13280a34b46e7f",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "e09c81d15493760f736d6b2020bae98c",
      "/app/commands/decidim/proposals/admin/answer_proposal.rb" => "04a1391daacc5f82eaffd675fde73b8f",
      "/app/forms/decidim/proposals/proposal_form.rb" => "ffa0fa0d38a9c77d73d173727bc87cd2",
      "/app/views/decidim/proposals/proposals/preview.html.erb" => "b9c6a7d417a5fa18bc96dea846a581ed",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "ba8c88bdf07061fda1962c54868c9131",
      "/app/views/decidim/proposals/proposals/edit.html.erb" => "6d34fd034334d83c60632cf478530d98",
      "/app/views/decidim/proposals/proposals/index.html.erb" => "cd4be96ca73de79b0f8d82f0f80f00e7",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "3e51c7a14d250a1abef0753a1db7661b",
      "/app/views/decidim/proposals/admin/proposals/_proposal-tr.html.erb" => "608af89f7bfa800fe2e3c853f8e2ace0",
      "/app/views/decidim/proposals/admin/proposals/show.html.erb" => "541d1f188e12c6c6ccf18d8908165d81",
      "/app/commands/decidim/proposals/admin/assign_proposals_to_evaluator.rb" => "1b59364e9808128809831c57e9ed93a3",
      "/app/permissions/decidim/proposals/admin/permissions.rb" => "34e652c5be8db79d4b5f8e9a7c6b808e",
      "/app/controllers/decidim/proposals/admin/proposal_answers_controller.rb" => "3317aaa495ce3563ae6d150229f90ca9",
      "/app/controllers/decidim/proposals/admin/evaluation_assignments_controller.rb" => "67b1583b2483bbb09ebfa13b7194a11a",
      "/app/views/decidim/proposals/proposals/show.html.erb" => "e2c0adf5c283f7396d93207e1b7ab740",
      "/app/views/decidim/proposals/proposals/_wizard_header.html.erb" => "60700214b35bbca30979a1ca4d0b0bb6",
      "/app/views/decidim/proposals/admin/proposal_notes/_proposal_notes.html.erb" => "37284cb43b9f3e6928ad7637e45d4e54",
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
      "/app/forms/decidim/budgets/admin/project_form.rb" => "90ab61e6ea470540bca5378fe21663cc"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/forms/decidim/meetings/admin/close_meeting_form.rb" => "de3f7cce87a91154e05122c2b44db045",
      "/app/forms/decidim/meetings/close_meeting_form.rb" => "9ccf72f8fa7d10e107e4561c033a7a63",
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
