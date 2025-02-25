class Upvote < ApplicationRecord
  belongs_to :user
  belongs_to :voteable, polymorphic: true

  validates :user_id, uniqueness: { scope: [:voteable_type, :voteable_id] }

  after_create :increment_upvotes_count
  after_destroy :decrement_upvotes_count

  private

  def increment_upvotes_count
    if voteable.respond_to?(:upvotes_count)
      voteable.increment!(:upvotes_count)
    end
  end

  def decrement_upvotes_count
    if voteable.respond_to?(:upvotes_count)
      voteable.decrement!(:upvotes_count)
    end
  end
end
