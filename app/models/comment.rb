class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true
  belongs_to :parent, class_name: 'Comment', optional: true, counter_cache: :replies_count
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy
  has_many :upvotes, as: :voteable, dependent: :destroy

  validates :content, presence: true

  def upvote
    increment!(:upvotes_count)
  end
end

Post.find_each { |post| Post.reset_counters(post.id, :comments) }
