class AddAndPopulateSlugsAndPublicIds < ActiveRecord::Migration[7.1]
  def up
    say "Starting migration to add slugs and public IDs"
    
    # STEP 1: Add the columns first
    say "Adding columns..."
    
    unless column_exists?(:communities, :slug)
      say "Adding slug column to communities"
      add_column :communities, :slug, :string
    else
      say "communities.slug already exists"
    end
    
    unless column_exists?(:posts, :slug)
      say "Adding slug column to posts"
      add_column :posts, :slug, :string
    else
      say "posts.slug already exists"
    end
    
    unless column_exists?(:posts, :public_id)
      say "Adding public_id column to posts"
      add_column :posts, :public_id, :string
    else
      say "posts.public_id already exists"
    end
    
    unless column_exists?(:comments, :public_id)
      say "Adding public_id column to comments"
      add_column :comments, :public_id, :string
    else
      say "comments.public_id already exists"
    end
    
    # STEP 2: Generate random values directly in SQL
    say "Populating data..."
    
    # Generate random public_ids for posts
    say "Generating public_ids for posts"
    begin
      execute <<-SQL
        UPDATE posts
        SET public_id = SUBSTRING(MD5(RANDOM()::text), 1, 10)
        WHERE public_id IS NULL
      SQL
    rescue => e
      say "Error generating post public_ids: #{e.message}"
    end

    # Generate random public_ids for comments
    say "Generating public_ids for comments"
    begin
      execute <<-SQL
        UPDATE comments
        SET public_id = SUBSTRING(MD5(RANDOM()::text), 1, 10)
        WHERE public_id IS NULL
      SQL
    rescue => e
      say "Error generating comment public_ids: #{e.message}"
    end

    # Generate slugs for posts
    say "Generating slugs for posts"
    begin
      execute <<-SQL
        UPDATE posts
        SET slug = LOWER(REPLACE(REPLACE(title, ' ', '-'), '.', '-'))
        WHERE slug IS NULL
      SQL
    rescue => e
      say "Error generating post slugs: #{e.message}"
    end

    # Generate slugs for communities
    say "Generating slugs for communities"
    begin
      execute <<-SQL
        UPDATE communities
        SET slug = LOWER(REPLACE(REPLACE(name, ' ', '-'), '.', '-'))
        WHERE slug IS NULL
      SQL
    rescue => e
      say "Error generating community slugs: #{e.message}"
    end

    # STEP 3: Add indexes after populating data
    say "Adding indexes..."
    
    unless index_exists?(:communities, :slug)
      say "Adding index on communities.slug"
      add_index :communities, :slug, unique: true
    else
      say "Index on communities.slug already exists"
    end
    
    unless index_exists?(:posts, :slug)
      say "Adding index on posts.slug"
      add_index :posts, :slug, unique: true
    else
      say "Index on posts.slug already exists"
    end
    
    unless index_exists?(:posts, :public_id)
      say "Adding index on posts.public_id"
      add_index :posts, :public_id, unique: true
    else
      say "Index on posts.public_id already exists"
    end
    
    unless index_exists?(:comments, :public_id)
      say "Adding index on comments.public_id"
      add_index :comments, :public_id, unique: true
    else
      say "Index on comments.public_id already exists"
    end
    
    say "Migration completed successfully"
  end

  def down
    say "Rolling back migration..."
    
    if index_exists?(:communities, :slug)
      say "Removing index on communities.slug"
      remove_index :communities, :slug
    end
    
    if index_exists?(:posts, :slug)
      say "Removing index on posts.slug"
      remove_index :posts, :slug
    end
    
    if index_exists?(:posts, :public_id)
      say "Removing index on posts.public_id"
      remove_index :posts, :public_id
    end
    
    if index_exists?(:comments, :public_id)
      say "Removing index on comments.public_id"
      remove_index :comments, :public_id
    end

    if column_exists?(:communities, :slug)
      say "Removing slug column from communities"
      remove_column :communities, :slug
    end
    
    if column_exists?(:posts, :slug)
      say "Removing slug column from posts"
      remove_column :posts, :slug
    end
    
    if column_exists?(:posts, :public_id)
      say "Removing public_id column from posts"
      remove_column :posts, :public_id
    end
    
    if column_exists?(:comments, :public_id)
      say "Removing public_id column from comments"
      remove_column :comments, :public_id
    end
    
    say "Rollback completed successfully"
  end
end 