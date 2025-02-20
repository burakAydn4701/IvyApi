# app/models/community.rb
class Community < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  # Cloudinary image upload
  has_one_attached :profile_photo
  has_one_attached :banner

  # Custom JSON representation
  def as_json(options = {})
    super(options.merge(
      include: {
        profile_photo: { methods: :url },
        banner: { methods: :url }
      }
    ))
  end

  has_many :posts

  def attach_profile_picture(image)
    if image.present?
      begin
        # Use the tempfile path directly for Cloudinary upload
        result = Cloudinary::Uploader.upload(image.tempfile.path)
        self.profile_photo = result['secure_url']
      rescue => e
        Rails.logger.error "Cloudinary upload failed: #{e.message}"
        raise e
      end
    end
  end

  def attach_banner(image)
    if image.present?
      begin
        # Use the tempfile path directly for Cloudinary upload
        result = Cloudinary::Uploader.upload(image.tempfile.path)
        self.banner = result['secure_url']
      rescue => e
        Rails.logger.error "Cloudinary upload failed: #{e.message}"
        raise e
      end
    end
  end
end