class FixDuplicateSlugs < ActiveRecord::Migration[7.1]
  def up
    # First, identify duplicate slugs
    execute <<-SQL
      CREATE TEMPORARY TABLE duplicate_slugs AS
      SELECT slug
      FROM posts
      WHERE slug IS NOT NULL
      GROUP BY slug
      HAVING COUNT(*) > 1;
    SQL
    
    # Then update the duplicates with a unique suffix
    execute <<-SQL
      UPDATE posts
      SET slug = slug || '-' || id
      WHERE slug IN (SELECT slug FROM duplicate_slugs)
      AND id NOT IN (
        SELECT MIN(id)
        FROM posts
        WHERE slug IN (SELECT slug FROM duplicate_slugs)
        GROUP BY slug
      );
    SQL
    
    # Now try to create the indexes
    begin
      add_index :communities, :slug, unique: true unless index_exists?(:communities, :slug)
    rescue => e
      puts "Error adding index to communities.slug: #{e.message}"
    end
    
    begin
      add_index :posts, :slug, unique: true unless index_exists?(:posts, :slug)
    rescue => e
      puts "Error adding index to posts.slug: #{e.message}"
    end
    
    begin
      add_index :posts, :public_id, unique: true unless index_exists?(:posts, :public_id)
    rescue => e
      puts "Error adding index to posts.public_id: #{e.message}"
    end
    
    begin
      add_index :comments, :public_id, unique: true unless index_exists?(:comments, :public_id)
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