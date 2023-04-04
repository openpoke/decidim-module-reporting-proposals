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
      "/lib/decidim/map/autocomplete.rb" => "65df8e58433814e6b35b52c1bff19ed2",
      "/lib/decidim/form_builder.rb" => "3ea9c3c51ea6e5e54d293326a529d27a",
      "/app/commands/decidim/create_report.rb" => "41c95f194f5ccb5ff32efc43644c9ce5",
      "/app/models/decidim/category.rb" => "f3a51a9e8377f8a658a35363ce1ba8c1",
      "/app/models/decidim/participatory_space_role_config/valuator.rb" => "8dbcc7c787a7db6e9cdebccf888ffbdf",
      "/app/presenters/decidim/resource_locator_presenter.rb" => "84a195ea879885bd7fa78dfa51ee7f12",
      "/lib/decidim/resource_manifest.rb" => "11c8017bd3da34f681d3b455e7d39191"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/forms/decidim/admin/category_form.rb" => "4cdbf72459b69b70cbdb4d682a990269",
      "/app/commands/decidim/admin/create_category.rb" => "6c0bc65edbb15257ddcd4bf9589cbeb4",
      "/app/commands/decidim/admin/update_category.rb" => "1171c2788dfc99975be24a211039f403",
      "/app/controllers/decidim/admin/categories_controller.rb" => "8d5fde8bb9437f73559cff7a3f812ff9",
      "/app/views/decidim/admin/categories/index.html.erb" => "c02468d9ad4f74c46408075b1ec0770b",
      "/app/views/decidim/admin/categories/_form.html.erb" => "9e087278afdd7bd948595487867ecba1"
    }
  },
  {
    package: "decidim-templates",
    files: {
      # "/app/controllers/decidim/templates/admin/proposal_answer_templates_controller.rb" => "11677320c5263e2fe13371ec2d057480"
    }
  },
  {
    package: "decidim-proposals",
    files: {
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "81075a969be2732d21f244eff3c4c56e",
      "/app/helpers/decidim/proposals/proposal_wizard_helper.rb" => "75d875f3323e75273819d526731140da",
      "/app/commands/decidim/proposals/create_proposal.rb" => "8808a4239d750a86edd6e9c309533788",
      "/app/forms/decidim/proposals/proposal_form.rb" => "ec488556b51b8f28c5031552b04844c1",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "085e99f32228bbf0a6d1089ade641d71",
      "/app/views/decidim/proposals/proposals/edit.html.erb" => "7071f1e5e10a22e79511875c50ce63be",
      "/app/views/decidim/proposals/proposals/edit_draft.html.erb" => "0b832f705872e1aea3eefbd76ef4f1fa",
      "/app/views/decidim/proposals/proposals/_edit_form_fields.html.erb" => "6893bb3cc0fe99f4de986f829af26d50",
      "/app/views/decidim/proposals/admin/proposals/_proposal-tr.html.erb" => "b1076d75afb140ded26d4837618f2af5",
      "/app/views/decidim/proposals/admin/proposals/show.html.erb" => "653949a89a736379aca2ce4efe44203d",
      "/app/permissions/decidim/proposals/admin/permissions.rb" => "751b15ced553b17b7203f66a0152fb75",
      "/app/controllers/decidim/proposals/admin/proposal_answers_controller.rb" => "51f25d8b36bca87fe5cb2637149b45fb",
      "/app/views/decidim/proposals/proposals/show.html.erb" => "f27bbec257eb6da28dbdd07ac0a224a5",
      "/app/views/decidim/proposals/proposals/_proposal_similar.html.erb" => "c530c9ee044c1ca3fb9a92c4abcfe3b2",
      "/app/views/decidim/proposals/proposals/_wizard_header.html.erb" => "ff854b9f14b712aa7e1972ca23a54e25",
      "/app/views/decidim/proposals/admin/proposal_notes/_proposal_notes.html.erb" => "058a26c30a66477e76fb6e84d9618d5e",
      "/app/events/decidim/proposals/publish_proposal_event.rb" => "09a89a62bd06731b12acc8589e1e998f",
      "/app/commands/decidim/proposals/publish_proposal.rb" => "6d5a18f4a50842c0223ccf51d7f8d405"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    # rubocop:disable Rails/DynamicFindBy
    spec = ::Gem::Specification.find_by_name(item[:package])
    # rubocop:enable Rails/DynamicFindBy
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
