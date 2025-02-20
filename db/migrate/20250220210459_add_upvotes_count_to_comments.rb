class AddUpvotesCountToComments < ActiveRecord::Migration[8.0]
  def change
    add_column :comments, :upvotes_count, :integer
  end
end
