class AddSlugsAndPublicIds < ActiveRecord::Migration[7.1]
  def change
    # Add slugs to communities
    add_column :communities, :slug, :string
    add_index :communities, :slug, unique: true

    # Add slugs and public_ids to posts
    add_column :posts, :slug, :string
    add_column :posts, :public_id, :string
    add_index :posts, :slug, unique: true
    add_index :posts, :public_id, unique: true

    # Add public_ids to comments
    add_column :comments, :public_id, :string
    add_index :comments, :public_id, unique: true
  end
end 