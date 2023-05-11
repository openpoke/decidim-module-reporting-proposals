# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module ResourceHelperOverride
      extend ActiveSupport::Concern

      included do
        def linked_resources_for(resource, type, link_name)
          linked_resources = resource.linked_resources(type, link_name).group_by { |linked_resource| linked_resource.class.name }
          linked_resources.merge!(resource.linked_resources(:reporting_proposals, link_name).group_by { |linked_resource| linked_resource.class.name }) if type == :proposals

          safe_join(linked_resources.map do |klass, resources|
            resource_manifest = klass.constantize.resource_manifest
            content_tag(:div, class: "section") do
              i18n_name = "#{resource.class.name.demodulize.underscore}_#{resource_manifest.name}"
              content_tag(:h3, I18n.t(i18n_name, scope: "decidim.resource_links.#{link_name}"), class: "section-heading") +
                render(partial: resource_manifest.template, locals: { resources: resources })
            end
          end)
        end
      end
    end
  end
end
