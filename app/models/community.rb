class Community < ApplicationRecord
  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  # Associations
  has_many :posts

  # Custom JSON representation
  def as_json(options = {})
    super(options).merge(
      profile_photo_url: self.profile_photo,
      banner_url: self.banner
    )
  end

  # Attach profile photo via Cloudinary
  def attach_profile_picture(uploaded_file)
    return unless uploaded_file.present?

    begin
      result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path)
      update(profile_photo: result['secure_url'])
    rescue => e
      Rails.logger.error "Cloudinary profile picture upload failed: #{e.message}"
      raise e
    end
  end

  # Attach banner via Cloudinary
  def attach_banner(uploaded_file)
    return unless uploaded_file.present?

    begin
      result = Cloudinary::Uploader.upload(uploaded_file.tempfile.path)
      update(banner: result['secure_url'])
    rescue => e
      Rails.logger.error "Cloudinary banner upload failed: #{e.message}"
      raise e
    end
  end
end
