class SetDefaultUpvotesCountOnPosts < ActiveRecord::Migration[7.0]
  def change
    change_column_default :posts, :upvotes_count, from: nil, to: 0
    change_column_null :posts, :upvotes_count, false, 0
  end
end 