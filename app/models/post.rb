class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  has_many :comments, dependent: :destroy
  has_many :upvotes, as: :voteable, dependent: :destroy
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

  # Method to get the author's name
  def author_name
    user.username if user.present?
  end

  def upvoted_by_current_user(current_user)
    upvotes.exists?(user: current_user)
  end
end
