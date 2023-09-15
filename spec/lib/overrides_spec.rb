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
      "/lib/decidim/map/autocomplete.rb" => "ebb08d858ca97b8f94c3db6072357598",
      "/lib/decidim/form_builder.rb" => "bf93115683b45fc7b9ecd6e17e25ebc1",
      "/app/helpers/decidim/resource_helper.rb" => "78a09dc6a9430a3f00e6c34abd51c14a",
      "/app/commands/decidim/create_report.rb" => "d871d245789e6f20f8197a4d7939889d",
      "/app/commands/decidim/gallery_methods.rb" => "2b1d3b8f67f9e8f5516605acc2acb053",
      "/app/models/decidim/category.rb" => "fc044f23d00373d62693ee7f044558fe",
      "/app/models/decidim/participatory_space_role_config/valuator.rb" => "8dbcc7c787a7db6e9cdebccf888ffbdf",
      "/app/mailers/decidim/reported_mailer.rb" => "1d027b93e14e662d7e6f7cc9814e67b5",
      "/app/presenters/decidim/resource_locator_presenter.rb" => "84a195ea879885bd7fa78dfa51ee7f12"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/forms/decidim/admin/category_form.rb" => "a4ced91742c31e508e381a05ee865ea2",
      "/app/commands/decidim/admin/create_category.rb" => "d8dbdd1eeaa3d43d849e614b417251d8",
      "/app/commands/decidim/admin/update_category.rb" => "a201920bf2f026694f26dae3b10a73f5",
      "/app/commands/decidim/admin/hide_resource.rb" => "3b242efd1b7e86b30d861a7162312eb1",
      "/app/controllers/decidim/admin/categories_controller.rb" => "07eb3f5f4fdf3a1e71b4bc0fa9be46aa",
      "/app/views/decidim/admin/categories/index.html.erb" => "4e1d63ff8ef26d91102b0f41b745ff4b",
      "/app/views/decidim/admin/categories/_form.html.erb" => "b6a178b11d2a68cfff9aeefb14fd6ab4"
    }
  },
  {
    package: "decidim-templates",
    files: {
      "/app/commands/decidim/templates/admin/copy_questionnaire_template.rb" => "ee7a0eb341baca868b8e7169e8871106",
      "/app/commands/decidim/templates/admin/create_questionnaire_template.rb" => "5a9a8f92416c04aeaf7123a934118544"
    }
  },
  {
    package: "decidim-proposals",
    files: {
      "/lib/decidim/proposals/component.rb" => "cf5b88a9b882643e437ec19f2bc83885",
      "/app/events/decidim/proposals/publish_proposal_event.rb" => "09a89a62bd06731b12acc8589e1e998f",
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "b263741e3335110fa0e37c488c777190",
      "/app/helpers/decidim/proposals/proposal_wizard_helper.rb" => "410442b7f68baf7e7d9983494a2ae7d6",
      "/app/commands/decidim/proposals/create_proposal.rb" => "7a6b8a1ea733e1e331b5251accfc9126",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "1e7e3c982b4cfd6806f0719cc985f2d1",
      "/app/commands/decidim/proposals/admin/answer_proposal.rb" => "4ee0bce9fc065ed1b7b03a8cd05ccc2f",
      "/app/forms/decidim/proposals/proposal_form.rb" => "5fbf98057d0e60a7beae161a37fdd31c",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "fb782e901c26e181a2998523b206925f",
      "/app/views/decidim/proposals/proposals/edit.html.erb" => "03b38c86774c20188ab41bf45027f4d4",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "983f3378b26bf51ec34247277acae429",
      "/app/views/decidim/proposals/proposals/_edit_form_fields.html.erb" => "3cf530a07e4498195dab8d94b7df19d1",
      "/app/views/decidim/proposals/admin/proposals/_proposal-tr.html.erb" => "b1076d75afb140ded26d4837618f2af5",
      "/app/views/decidim/proposals/admin/proposals/show.html.erb" => "bd36bf5588cdd7293f44dc1146fecc49",
      "/app/commands/decidim/proposals/admin/assign_proposals_to_valuator.rb" => "595ed7561131c9ee8a79bb4806f7a9bb",
      "/app/permissions/decidim/proposals/admin/permissions.rb" => "751b15ced553b17b7203f66a0152fb75",
      "/app/controllers/decidim/proposals/admin/proposal_answers_controller.rb" => "51f25d8b36bca87fe5cb2637149b45fb",
      "/app/controllers/decidim/proposals/admin/valuation_assignments_controller.rb" => "c558d21a69ea1c9c9e7d70fdc8f7d20e",
      "/app/views/decidim/proposals/proposals/show.html.erb" => "f27bbec257eb6da28dbdd07ac0a224a5",
      "/app/views/decidim/proposals/proposals/_proposal_similar.html.erb" => "c530c9ee044c1ca3fb9a92c4abcfe3b2",
      "/app/views/decidim/proposals/proposals/_wizard_header.html.erb" => "ff854b9f14b712aa7e1972ca23a54e25",
      "/app/views/decidim/proposals/admin/proposal_notes/_proposal_notes.html.erb" => "058a26c30a66477e76fb6e84d9618d5e",
      "/app/cells/decidim/proposals/proposals_picker_cell.rb" => "a90bce30cd07ed77b3d2dbc0c2774f6a"
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
      "/app/forms/decidim/budgets/admin/project_form.rb" => "5eb2d5d95ca783c700ffe7703f1583dc"
    }
  },
  {
    package: "decidim-elections",
    files: {
      "/app/forms/decidim/elections/admin/answer_form.rb" => "082e6529c78cee6e2b9b78368ca4ca46"
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
