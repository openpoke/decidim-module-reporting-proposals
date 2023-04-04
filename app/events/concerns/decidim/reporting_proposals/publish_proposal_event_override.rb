# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module PublishProposalEventOverride
      extend ActiveSupport::Concern

      included do
        def i18n_options
          return super if author.blank?

          author_path = link_to("@#{author.nickname}", profile_path(author.nickname))
          author_string = "#{author.name} #{author_path}"
          resource_admin_url ||= Decidim::ResourceLocatorPresenter.new(resource).admin_url
          resource_admin_path = link_to(I18n.t(".admin_panel", scope: i18n_scope), resource_admin_url)

          super.merge({ author: author_string, admin_url: resource_admin_path })
        end
      end
    end
  end
end
