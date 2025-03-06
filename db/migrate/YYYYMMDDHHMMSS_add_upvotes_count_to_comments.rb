class AddUpvotesCountToComments < ActiveRecord::Migration[6.0]
  def change
    add_column :comments, :upvotes_count, :integer, default: 0
  end
end