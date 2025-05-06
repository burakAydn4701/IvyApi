class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true, counter_cache: :replies_count
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :upvotes, as: :voteable, dependent: :destroy

  validates :content, presence: true
  validates :public_id, presence: true, uniqueness: true

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
    self.public_id = Nanoid.generate(size: 10) if public_id.nil?
  end
end

Post.find_each { |post| Post.reset_counters(post.id, :comments) }
