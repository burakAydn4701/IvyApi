class UpdateNullUpvotesCountOnPosts < ActiveRecord::Migration[7.0]
  def up
    Post.where(upvotes_count: nil).update_all(upvotes_count: 0)
  end

  def down
    # Optionally, you can define how to revert this change
  end
end 