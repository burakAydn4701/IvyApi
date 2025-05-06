class AddColumnsSimple < ActiveRecord::Migration[7.1]
  def change
    # Add columns to communities
    add_column :communities, :slug, :string unless column_exists?(:communities, :slug)
    
    # Add columns to posts
    add_column :posts, :slug, :string unless column_exists?(:posts, :slug)
    add_column :posts, :public_id, :string unless column_exists?(:posts, :public_id)
    
    # Add columns to comments
    add_column :comments, :public_id, :string unless column_exists?(:comments, :public_id)
    
    # Add indexes
    add_index :communities, :slug, unique: true unless index_exists?(:communities, :slug)
    add_index :posts, :slug, unique: true unless index_exists?(:posts, :slug)
    add_index :posts, :public_id, unique: true unless index_exists?(:posts, :public_id)
    add_index :comments, :public_id, unique: true unless index_exists?(:comments, :public_id)
  end
end 