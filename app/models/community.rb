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
end