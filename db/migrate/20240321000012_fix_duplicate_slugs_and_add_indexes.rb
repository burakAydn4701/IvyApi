class FixDuplicateSlugsAndAddIndexes < ActiveRecord::Migration[7.1]
  def up
    # First, identify and fix duplicate slugs in posts
    execute <<-SQL
      -- Create a temporary table to store duplicates
      CREATE TEMPORARY TABLE duplicate_post_slugs AS
      SELECT slug
      FROM posts
      WHERE slug IS NOT NULL
      GROUP BY slug
      HAVING COUNT(*) > 1;
      
      -- Update duplicates with a unique suffix
      UPDATE posts
      SET slug = slug || '-' || id
      WHERE slug IN (SELECT slug FROM duplicate_post_slugs)
      AND id NOT IN (
        SELECT MIN(id)
        FROM posts
        WHERE slug IN (SELECT slug FROM duplicate_post_slugs)
        GROUP BY slug
      );
    SQL
    
    # Check for any remaining duplicates
    duplicates = execute("
      SELECT COUNT(*) 
      FROM posts 
      GROUP BY slug 
      HAVING COUNT(*) > 1
    ")
    
    if duplicates.count > 0
      raise "There are still duplicate slugs in the posts table. Please fix them manually."
    end
    
    # Now add the indexes one by one with error handling
    begin
      add_index :communities, :slug, unique: true
    rescue => e
      puts "Error adding index to communities.slug: #{e.message}"
    end
    
    begin
      add_index :posts, :slug, unique: true
    rescue => e
      puts "Error adding index to posts.slug: #{e.message}"
    end
    
    begin
      add_index :posts, :public_id, unique: true
    rescue => e
      puts "Error adding index to posts.public_id: #{e.message}"
    end
    
    begin
      add_index :comments, :public_id, unique: true
    rescue => e
      puts "Error adding index to comments.public_id: #{e.message}"
    end
  end
  
  def down
    remove_index :communities, :slug if index_exists?(:communities, :slug)
    remove_index :posts, :slug if index_exists?(:posts, :slug)
    remove_index :posts, :public_id if index_exists?(:posts, :public_id)
    remove_index :comments, :public_id if index_exists?(:comments, :public_id)
  end
end 