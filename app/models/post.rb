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
  validates :public_id, presence: true, uniqueness: true, allow_nil: true
  validates :community_id, presence: true
  validates :user_id, presence: true

  before_validation :set_public_id, on: :create
  before_create :generate_slug

  # Method to get post content (for backward compatibility)
  def body
    content
  end

  # Updated method to handle image upload with WebP support
  def attach_image(image)
    upload_options = {
      resource_type: "auto",
      allowed_formats: ["jpg", "jpeg", "png", "gif", "webp"]
    }
    
    if image.present?
      uploaded_image = Cloudinary::Uploader.upload(image, upload_options)
      self.image_url = uploaded_image["secure_url"]
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
    return if public_id.present?
    
    # Use SecureRandom as a fallback if NanoidHelper is not defined
    if defined?(NanoidHelper)
      self.public_id = NanoidHelper.generate(size: 10)
    else
      require 'securerandom'
      self.public_id = SecureRandom.alphanumeric(10)
    end
  end

  def generate_slug
    return if slug.present?
    
    base_slug = title.parameterize
    self.slug = base_slug
    
    # Ensure uniqueness
    counter = 1
    while Post.exists?(slug: self.slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def generate_public_id
    return if public_id.present?
    
    self.public_id = SecureRandom.hex(5)
    
    # Ensure uniqueness
    while Post.exists?(public_id: self.public_id)
      self.public_id = SecureRandom.hex(5)
    end
  end
end
