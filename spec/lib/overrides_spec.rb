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
      "/lib/decidim/form_builder.rb" => "91c55f8197a9e3892e94f5c13ca40905",
      "/app/commands/decidim/create_report.rb" => "41c95f194f5ccb5ff32efc43644c9ce5"
    }
  },
  {
    package: "decidim-proposals",
    files: {
      "/app/controllers/decidim/proposals/proposals_controller.rb" => "6f73c3cad3c713358535c92e2ed84f60",
      "/app/helpers/decidim/proposals/proposal_wizard_helper.rb" => "75d875f3323e75273819d526731140da",
      "/app/commands/decidim/proposals/create_proposal.rb" => "8808a4239d750a86edd6e9c309533788",
      "/app/forms/decidim/proposals/proposal_form.rb" => "ec488556b51b8f28c5031552b04844c1",
      "/app/views/decidim/proposals/proposals/new.html.erb" => "085e99f32228bbf0a6d1089ade641d71",
      "/app/views/decidim/proposals/admin/proposals/_proposal-tr.html.erb" => "e0a162954ca45ab6b3d71e61635eddbd"
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
