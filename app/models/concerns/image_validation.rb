module ImageValidation
  extend ActiveSupport::Concern

  IMAGE_TYPES = %w[image/jpeg image/png image/webp image/gif image/avif].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  class_methods do
    def validates_images(*attributes, max_count: nil)
      validate do
        attributes.each do |attribute|
          attachments = Array(public_send(attribute).attachments).compact
          if max_count && attachments.size > max_count.call
            errors.add(attribute, :too_many_images, count: max_count.call)
          end
          attachments.each do |attachment|
            blob = attachment.blob
            errors.add(attribute, :invalid_image_type) unless IMAGE_TYPES.include?(blob.content_type)
            errors.add(attribute, :image_too_large, size: MAX_IMAGE_SIZE / 1.megabyte) if blob.byte_size > MAX_IMAGE_SIZE
          end
        end
      end
    end
  end
end
