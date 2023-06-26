# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/lib/decidim/component_validator.rb" => "2e3eb588a9579b94c21f4f440751d9a9",
      "/lib/decidim/map/autocomplete.rb" => "ebb08d858ca97b8f94c3db6072357598",
      "/lib/decidim/form_builder.rb" => "3ea9c3c51ea6e5e54d293326a529d27a",
      "/app/helpers/decidim/resource_helper.rb" => "78a09dc6a9430a3f00e6c34abd51c14a",
      "/app/commands/decidim/create_report.rb" => "41c95f194f5ccb5ff32efc43644c9ce5",
      "/app/models/decidim/category.rb" => "fc044f23d00373d62693ee7f044558fe",
      "/app/models/decidim/participatory_space_role_config/valuator.rb" => "8dbcc7c787a7db6e9cdebccf888ffbdf",
      "/app/mailers/decidim/reported_mailer.rb" => "1d027b93e14e662d7e6f7cc9814e67b5",
      "/app/presenters/decidim/resource_locator_presenter.rb" => "84a195ea879885bd7fa78dfa51ee7f12"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/forms/decidim/admin/category_form.rb" => "4cdbf72459b69b70cbdb4d682a990269",
      "/app/commands/decidim/admin/create_category.rb" => "d8dbdd1eeaa3d43d849e614b417251d8",
      "/app/commands/decidim/admin/update_category.rb" => "a201920bf2f026694f26dae3b10a73f5",
      "/app/commands/decidim/admin/hide_resource.rb" => "3b242efd1b7e86b30d861a7162312eb1",
      "/app/controllers/decidim/admin/categories_controller.rb" => "8d5fde8bb9437f73559cff7a3f812ff9",
      "/app/views/decidim/admin/categories/index.html.erb" => "c02468d9ad4f74c46408075b1ec0770b",
      "/app/views/decidim/admin/categories/_form.html.erb" => "9e087278afdd7bd948595487867ecba1"
    }
  },
  {
    package: "decidim-templates",
    files: {
      "/app/commands/decidim/templates/admin/copy_questionnaire_template.rb" => "4c8a7686cc05ad207bd7c041c99c4ef5",
      "/app/commands/decidim/templates/admin/create_questionnaire_template.rb" => "14b1479a6de1153c4396bfbaf2f05703"
    }
  },
  {
    package: "decidim-proposals",
    files: {
      "/lib/decidim/proposals/component.rb" => "cf5b88a9b882643e437ec19f2bc83885",
      "/app/events/decidim/proposals/publish_proposal_event.rb" => "09a89a62bd06731b12acc8589e1e998f",
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "81075a969be2732d21f244eff3c4c56e",
      "/app/helpers/decidim/proposals/proposal_wizard_helper.rb" => "75d875f3323e75273819d526731140da",
      "/app/commands/decidim/proposals/create_proposal.rb" => "8808a4239d750a86edd6e9c309533788",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "1e7e3c982b4cfd6806f0719cc985f2d1",
      "/app/commands/decidim/proposals/admin/answer_proposal.rb" => "4ee0bce9fc065ed1b7b03a8cd05ccc2f",
      "/app/forms/decidim/proposals/proposal_form.rb" => "ec488556b51b8f28c5031552b04844c1",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "085e99f32228bbf0a6d1089ade641d71",
      "/app/views/decidim/proposals/proposals/edit.html.erb" => "7071f1e5e10a22e79511875c50ce63be",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "983f3378b26bf51ec34247277acae429",
      "/app/views/decidim/proposals/proposals/_edit_form_fields.html.erb" => "6893bb3cc0fe99f4de986f829af26d50",
      "/app/views/decidim/proposals/admin/proposals/_proposal-tr.html.erb" => "b1076d75afb140ded26d4837618f2af5",
      "/app/views/decidim/proposals/admin/proposals/show.html.erb" => "653949a89a736379aca2ce4efe44203d",
      "/app/commands/decidim/proposals/admin/assign_proposals_to_valuator.rb" => "9f87025037a9f4e3f7b22e7b3d70da7c",
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
      "/app/forms/decidim/accountability/admin/result_form.rb" => "1b2a1c92532899b99570726bbcf11889",
      "/app/commands/decidim/accountability/admin/create_result.rb" => "3c1900b314ef0a6a801bee37bfa0934a",
      "/app/commands/decidim/accountability/admin/update_result.rb" => "31074f2fe62c7c49ddb9914b82326f4f"
    }
  },
  {
    package: "decidim-budgets",
    files: {
      "/app/forms/decidim/budgets/admin/project_form.rb" => "906fb91a57237fab33a3e74d24f21c37"
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
