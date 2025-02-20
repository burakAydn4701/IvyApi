class AddUpvotesCountToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :upvotes_count, :integer, default: 0, null: false
  end
end 