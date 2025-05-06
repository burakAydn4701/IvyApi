class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  belongs_to :community, optional: true
  has_many :comments, dependent: :destroy
  has_many :upvotes, as: :voteable, dependent: :destroy
  has_one_attached :image
  
  validates :title, presence: true
  validates :content, presence: true
  validates :public_id, presence: true, uniqueness: true

  before_validation :set_public_id, on: :create

  # Method to get post content (for backward compatibility)
  def body
    content
  end

  # Updated method to handle image upload with WebP support
  def attach_image(image)
    if image.present?
      # Add WebP support with minimal changes
      upload_options = {
        resource_type: "auto",  # Auto-detect resource type
        allowed_formats: ["jpg", "jpeg", "png", "gif", "webp"]  # Explicitly allow webp
      }
      
      result = Cloudinary::Uploader.upload(image, upload_options)
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

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  def to_param
    "#{public_id}-#{slug}"
  end

  private

  def set_public_id
    self.public_id = Nanoid.generate(size: 10) if public_id.nil?
  end
end
