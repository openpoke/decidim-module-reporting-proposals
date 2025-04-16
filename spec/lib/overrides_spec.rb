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
      "/lib/decidim/map/autocomplete.rb" => "c9249996707cb63d9b44f22a3441e1c5",
      "/lib/decidim/form_builder.rb" => "f8c91d2c47acef53aa4680eb72280703",
      "/app/helpers/decidim/resource_helper.rb" => "6e5c33c68581bbfabcf5bdd489d65a25",
      "/app/commands/decidim/create_report.rb" => "cbdd49b973903c6f02d583191eb03dd8",
      "/app/commands/decidim/gallery_methods.rb" => "9a33f44912059c9764691abb03f70a84",
      "/app/models/decidim/category.rb" => "fc044f23d00373d62693ee7f044558fe",
      "/app/models/decidim/participatory_space_role_config/valuator.rb" => "8dbcc7c787a7db6e9cdebccf888ffbdf",
      "/app/mailers/decidim/reported_mailer.rb" => "5561adb23aa90454341675d5f0539f2b",
      "/app/presenters/decidim/resource_locator_presenter.rb" => "84a195ea879885bd7fa78dfa51ee7f12",
      "/app/cells/decidim/linked_resources_for_cell.rb" => "7559a251620f5ca336c175a8d8ceabdc"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/forms/decidim/admin/category_form.rb" => "cb56a20226a48af9cebca68d3c612d6b",
      "/app/commands/decidim/admin/create_category.rb" => "299e5963abb82271941811437cad2a69",
      "/app/commands/decidim/admin/update_category.rb" => "815643f989f684c710152e4e783521f4",
      "/app/controllers/decidim/admin/categories_controller.rb" => "160983531f75124297089665afa89126",
      "/app/views/decidim/admin/categories/index.html.erb" => "4bc99338b97a7f2835b6931ec3573c4c",
      "/app/views/decidim/admin/categories/_form.html.erb" => "fbdcbd4745300402700b2ff386d7f56d"
    }
  },
  {
    package: "decidim-templates",
    files: {
      "/app/commands/decidim/templates/admin/update_proposal_answer_template.rb" => "9ee3f25f047e17a5b7041d43ba319183",
      "/app/controllers/decidim/templates/admin/proposal_answer_templates_controller.rb" => "2e5b52f17023709ca9575967ac1c3c41"
    }
  },
  {
    package: "decidim-proposals",
    files: {
      "/lib/decidim/proposals/component.rb" => "cb641eb641918f98ffd0ec23a2f759a4",
      "/app/events/decidim/proposals/publish_proposal_event.rb" => "085ba02d02310d94b462b43c973007c6",
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "1d942a2c1dac7cd541dec024f06afea1",
      "/app/helpers/decidim/proposals/proposal_wizard_helper.rb" => "330889e7edb2fbd3571391a32d3d02c8",
      "/app/commands/decidim/proposals/create_proposal.rb" => "02a6f54a032457e68be580e6a539c47b",
      "/app/commands/decidim/proposals/update_proposal.rb" => "e81268a1f9b3770387944d44d7704291",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "30c6c7e5504394e0a69a9776cc319b57",
      "/app/commands/decidim/proposals/admin/answer_proposal.rb" => "04a1391daacc5f82eaffd675fde73b8f",
      "/app/forms/decidim/proposals/proposal_form.rb" => "0b19bfeb4f7bd15cd378a69c3935de6b",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "ba8c88bdf07061fda1962c54868c9131",
      "/app/views/decidim/proposals/proposals/edit.html.erb" => "6d34fd034334d83c60632cf478530d98",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "3e51c7a14d250a1abef0753a1db7661b",
      "/app/views/decidim/proposals/proposals/_edit_form_fields.html.erb" => "5907a92b0adf9a0cd5f1e5241317cd48",
      "/app/views/decidim/proposals/admin/proposals/_proposal-tr.html.erb" => "057ee4242479109023a5904c8de55222",
      "/app/views/decidim/proposals/admin/proposals/show.html.erb" => "5dae5c5dc6b6c25a5b4cfc5cda5e9f01",
      "/app/commands/decidim/proposals/admin/assign_proposals_to_valuator.rb" => "adae22edfadd7db484165fee40558c3a",
      "/app/permissions/decidim/proposals/admin/permissions.rb" => "95a9ef93fca01ee27a658885079640a2",
      "/app/controllers/decidim/proposals/admin/proposal_answers_controller.rb" => "1a68a15c6589552dad41151a916f7fd1",
      "/app/controllers/decidim/proposals/admin/valuation_assignments_controller.rb" => "d8a767cb7069730b249da53a58e064e2",
      "/app/views/decidim/proposals/proposals/show.html.erb" => "ec5980ab50a4999b2a6975e61998ec1f",
      "/app/views/decidim/proposals/proposals/_wizard_header.html.erb" => "60700214b35bbca30979a1ca4d0b0bb6",
      "/app/views/decidim/proposals/admin/proposal_notes/_proposal_notes.html.erb" => "4fdc3a5f8e772c24b7510c4db90cd4c2",
      "/app/cells/decidim/proposals/proposals_picker_cell.rb" => "cf40967e6846216ed73f7eaa1ae3d09e"
    }
  },
  {
    package: "decidim-accountability",
    files: {
      "/app/forms/decidim/accountability/admin/result_form.rb" => "8053adbe13076ce443a863c0ac79184b",
      "/app/commands/decidim/accountability/admin/create_result.rb" => "a2e559d46be517d175fed47d3d538db4",
      "/app/commands/decidim/accountability/admin/update_result.rb" => "696b3ca391a7b6ac1338cbddcc88682c"
    }
  },
  {
    package: "decidim-budgets",
    files: {
      "/app/forms/decidim/budgets/admin/project_form.rb" => "f3ed687e3c7208bd16479da2b0eeebac"
    }
  },
  {
    package: "decidim-meetings",
    files: {
      "/app/forms/decidim/meetings/admin/close_meeting_form.rb" => "f035ac3dae2ae4b008cfc3165f0f0409",
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
