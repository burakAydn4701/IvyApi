class AddUpvotesCountToComments < ActiveRecord::Migration[7.0]
  def change
    add_column :comments, :upvotes_count, :integer, default: 0, null: false
  end
end 