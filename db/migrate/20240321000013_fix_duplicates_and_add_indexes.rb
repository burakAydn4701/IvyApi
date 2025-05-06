class FixDuplicatesAndAddIndexes < ActiveRecord::Migration[7.1]
  def up
    # First, identify and fix duplicate slugs in posts
    execute <<-SQL
      -- Create a temporary table to store duplicates
      CREATE TEMPORARY TABLE IF NOT EXISTS duplicate_post_slugs AS
      SELECT slug, array_agg(id) as post_ids
      FROM posts
      WHERE slug IS NOT NULL
      GROUP BY slug
      HAVING COUNT(*) > 1;
      
      -- Update duplicates with a unique suffix (keep the first one as is)
      WITH duplicates AS (
        SELECT slug, unnest(post_ids) as id, 
               row_number() OVER (PARTITION BY slug ORDER BY unnest(post_ids)) as rn
        FROM duplicate_post_slugs
      )
      UPDATE posts
      SET slug = slug || '-' || id
      FROM duplicates
      WHERE posts.id = duplicates.id
      AND duplicates.rn > 1;
    SQL
    
    # Now add the indexes one by one with error handling
    begin
      add_index :communities, :slug, unique: true, if_not_exists: true
      puts "Successfully added unique index on communities.slug"
    rescue => e
      puts "Error adding index to communities.slug: #{e.message}"
    end
    
    begin
      add_index :posts, :slug, unique: true, if_not_exists: true
      puts "Successfully added unique index on posts.slug"
    rescue => e
      puts "Error adding index to posts.slug: #{e.message}"
    end
    
    begin
      add_index :posts, :public_id, unique: true, if_not_exists: true
      puts "Successfully added unique index on posts.public_id"
    rescue => e
      puts "Error adding index to posts.public_id: #{e.message}"
    end
    
    begin
      add_index :comments, :public_id, unique: true, if_not_exists: true
      puts "Successfully added unique index on comments.public_id"
    rescue => e
      puts "Error adding index to comments.public_id: #{e.message}"
    end
  end
  
  def down
    remove_index :communities, :slug, if_exists: true
    remove_index :posts, :slug, if_exists: true
    remove_index :posts, :public_id, if_exists: true
    remove_index :comments, :public_id, if_exists: true
  end
end 