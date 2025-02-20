class AddUpvotesCountToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :upvotes_count, :integer
  end
end
