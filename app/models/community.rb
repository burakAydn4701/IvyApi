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

  def attach_profile_picture(uploaded_file)
    if uploaded_file.present?
      begin
        # Get the actual file data from the uploaded file
        file_path = uploaded_file.try(:tempfile) ? uploaded_file.tempfile.path : uploaded_file.path
        result = Cloudinary::Uploader.upload(file_path)
        self.profile_photo = result['secure_url']
      rescue => e
        Rails.logger.error "Cloudinary profile picture upload failed: #{e.message}"
        raise e
      end
    end
  end

  def attach_banner(uploaded_file)
    if uploaded_file.present?
      begin
        # Get the actual file data from the uploaded file
        file_path = uploaded_file.try(:tempfile) ? uploaded_file.tempfile.path : uploaded_file.path
        result = Cloudinary::Uploader.upload(file_path)
        self.banner = result['secure_url']
      rescue => e
        Rails.logger.error "Cloudinary banner upload failed: #{e.message}"
        raise e
      end
    end
  end
end