class Community < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  # Associations
  belongs_to :user
  has_many :posts, dependent: :destroy

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

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
