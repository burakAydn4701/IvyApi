class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true, counter_cache: :replies_count
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :upvotes, as: :voteable, dependent: :destroy

  validates :content, presence: true
  validates :public_id, uniqueness: true, allow_nil: true

  before_validation :set_public_id, on: :create

  def to_param
    public_id
  end

  def upvote
    increment!(:upvotes_count)
  end

  def upvoted_by_current_user(current_user)
    upvotes.exists?(user: current_user)
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
end

# This line should be in a separate migration or rake task, not in the model file
# Post.find_each { |post| Post.reset_counters(post.id, :comments) }
