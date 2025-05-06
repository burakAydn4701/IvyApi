class AddColumnsSimpleNoIndex < ActiveRecord::Migration[7.1]
  def change
    # Add columns to communities
    add_column :communities, :slug, :string
    
    # Add columns to posts
    add_column :posts, :slug, :string
    add_column :posts, :public_id, :string
    
    # Add columns to comments
    add_column :comments, :public_id, :string
  end
end 