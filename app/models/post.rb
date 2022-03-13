class Post < ApplicationRecord
  has_rich_text :content

  validates :title, length: { maximum: 32 }, presence: true

  validate :validate_content_length
  validate :validate_byte_size
  validate :validate_number_of_attachment

  MAX_CONTENT_LENGTH = 50

  ONE_KILO_BYTE = 1024
  MAX_MEGA_BYTE_SIZE = 1
  MAX_CONTENT_ATTACHMENT_BYTE_SIZE = MAX_MEGA_BYTE_SIZE * ONE_KILO_BYTE * 1_000

  MAX_NUMBER_OF_ATTACHMENT = 4

  private

    def validate_content_length
      length = content.to_plain_text.length
      if length > MAX_CONTENT_LENGTH
        errors.add(:content, :too_long, max_content_length: MAX_CONTENT_LENGTH, length: length)
      end
    end

    def validate_byte_size
      content.body.attachables.grep(ActiveStorage::Blob) do |attachable|
        byte_size = attachable.byte_size

        if byte_size > MAX_CONTENT_ATTACHMENT_BYTE_SIZE
          errors.add(
            :base,
            :content_attachment_is_too_big,
            max_content_attachment_byte_size: MAX_CONTENT_ATTACHMENT_BYTE_SIZE,
            byte_size: byte_size,
            max_mega_bite_size: MAX_MEGA_BYTE_SIZE
          )
        end
      end
    end

    def validate_number_of_attachment
      number_of_attachment = content.body.attachables.grep(ActiveStorage::Blob).count

      if number_of_attachment > MAX_NUMBER_OF_ATTACHMENT
        errors.add(
          :base,
          :content_attachment_number_is_too_many,
          number_of_attachment: number_of_attachment,
          max_number_of_attachment: MAX_NUMBER_OF_ATTACHMENT
        )
      end
    end
end
