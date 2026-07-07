# frozen_string_literal: true

module Decidim
  module ReportingProposals
    # Builds and persists the proposal `photos` attachments (camera button).
    # TODO (hotfix): vendored concern – long-term route photos through core `attachments` and drop this.
    module PhotoMethods
      private

      def build_photos(attached_to = nil)
        @gallery = []
        @form.add_photos.compact_blank.each do |photo|
          if photo.is_a?(Hash) && photo.has_key?(:id)
            update_photo_title_for(photo)
            next
          end

          @gallery << Attachment.new(
            title: photos_title(photo),
            attached_to: attached_to || photos_attached_to,
            file: photos_signed_id(photo),
            content_type: photos_content_type(photo)
          )
        end
      end

      def update_photo_title_for(photo)
        Decidim::Attachment.find(photo[:id]).update(title: photos_title(photo))
      end

      def photos_invalid?
        @gallery.each do |photo|
          if photo.invalid? && photo.errors.has_key?(:file)
            @form.errors.add(:add_photos, photo.errors[:file])
            return true
          end
        end
        false
      end

      def create_photos(first_weight: 0)
        weight = first_weight
        @form.photos.each do |photo|
          photo.update!(weight:)
          weight += 1
        end
        @gallery.map! do |photo|
          photo.weight = weight
          photo.attached_to = photos_attached_to
          photo.save!
          weight += 1
          @form.photos << photo
        end
      end

      def photo_cleanup!
        photos_attached_to.photos.each do |photo|
          next unless @form.photos.map(&:id).exclude?(photo.id)

          # skip attachments still referenced by the form
          photo.destroy! if (@form.respond_to?(:attachments) && @form.attachments.map(&:id).exclude?(photo.id)) || !@form.respond_to?(:attachments)
        end
        # manually reset cached photos
        photos_attached_to.reload
        photos_attached_to.instance_variable_set(:@photos, nil)
      end

      def photos_allowed?
        @form.current_component.settings.attachments_allowed?
      end

      def process_photos?
        photos_allowed? && @form.add_photos.any?
      end

      def photos_attached_to
        return @attached_to if @attached_to.present?
        return form.current_organization if form.respond_to?(:current_organization)

        form.current_component.organization if form.respond_to?(:current_component)
      end

      def photos_signed_id(photo)
        return photo[:file] if photo.is_a?(Hash)

        photo
      end

      def photos_title(photo)
        return { I18n.locale => photo[:title] } if photo.is_a?(Hash) && photo.has_key?(:title)

        { I18n.locale => "" }
      end

      def photos_content_type(photo)
        photo_blob(photos_signed_id(photo)).content_type
      end

      def photo_blob(signed_id)
        ActiveStorage::Blob.find_signed(signed_id)
      end
    end
  end
end
