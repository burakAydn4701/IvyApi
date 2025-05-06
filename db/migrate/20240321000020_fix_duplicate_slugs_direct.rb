class FixDuplicateSlugsDirectly < ActiveRecord::Migration[7.1]
  def up
    # First, directly fix duplicate slugs using SQL
    execute <<-SQL
      -- Fix duplicate slugs in posts table
      WITH duplicates AS (
        SELECT slug, array_agg(id) as ids
        FROM posts
        WHERE slug IS NOT NULL
        GROUP BY slug
        HAVING COUNT(*) > 1
      )
      UPDATE posts
      SET slug = posts.slug || '-' || posts.id
      FROM duplicates
      WHERE posts.slug = duplicates.slug
      AND posts.id <> (SELECT MIN(id) FROM posts p WHERE p.slug = duplicates.slug);
    SQL
    
    puts "Fixed duplicate slugs in posts table"
    
    # Now try to add the indexes directly
    begin
      execute("CREATE UNIQUE INDEX IF NOT EXISTS index_communities_on_slug ON communities (slug);")
      puts "Successfully added unique index on communities.slug"
    rescue => e
      puts "Error adding index to communities.slug: #{e.message}"
    end
    
    begin
      execute("CREATE UNIQUE INDEX IF NOT EXISTS index_posts_on_slug ON posts (slug);")
      puts "Successfully added unique index on posts.slug"
    rescue => e
      puts "Error adding index to posts.slug: #{e.message}"
    end
    
    begin
      execute("CREATE UNIQUE INDEX IF NOT EXISTS index_posts_on_public_id ON posts (public_id);")
      puts "Successfully added unique index on posts.public_id"
    rescue => e
      puts "Error adding index to posts.public_id: #{e.message}"
    end
    
    begin
      execute("CREATE UNIQUE INDEX IF NOT EXISTS index_comments_on_public_id ON comments (public_id);")
      puts "Successfully added unique index on comments.public_id"
    rescue => e
      puts "Error adding index to comments.public_id: #{e.message}"
    end
  end
  
  def down
    execute("DROP INDEX IF EXISTS index_communities_on_slug;")
    execute("DROP INDEX IF EXISTS index_posts_on_slug;")
    execute("DROP INDEX IF EXISTS index_posts_on_public_id;")
    execute("DROP INDEX IF EXISTS index_comments_on_public_id;")
  end
end 