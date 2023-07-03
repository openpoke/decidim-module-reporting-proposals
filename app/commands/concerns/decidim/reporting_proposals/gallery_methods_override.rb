# frozen_string_literal: true

module Decidim
  module ReportingProposals
    module GalleryMethodsOverride
      extend ActiveSupport::Concern

      # this method cannot process direct uploads in gallery_methods.rb so we override it here with the fix
      included do
        def photos_content_type(photo)
          return blob(photos_signed_id(photo)).content_type if photo.is_a?(Hash)

          photo.content_type
        end
      end
    end
  end
end
