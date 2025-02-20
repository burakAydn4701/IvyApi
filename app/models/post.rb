class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  has_many :comments
  has_many :upvotes, as: :voteable
  has_one_attached :image
  
  validates :title, presence: true
  validates :content, presence: true

  # Add method to handle image upload
  def attach_image(image)
    if image.present?
      result = Cloudinary::Uploader.upload(image)
      self.image_url = result['secure_url']
    end
  end

  def upvote
    increment!(:upvotes_count)
  end
end
