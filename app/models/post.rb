class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community, optional: true
  has_many :comments, dependent: :destroy
  has_many :upvotes, as: :voteable, dependent: :destroy
  has_one_attached :image
  
  validates :title, presence: true
  validates :content, presence: true
  
  # Method to get post content (for backward compatibility)
  def body
    content
  end

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
  
  # Helper method to get upvotes count safely
  def upvotes_count
    # Use the database counter cache if available, otherwise count manually
    if has_attribute?(:upvotes_count) && self[:upvotes_count].present?
      self[:upvotes_count]
    else
      upvotes.count
    end
  end
end
