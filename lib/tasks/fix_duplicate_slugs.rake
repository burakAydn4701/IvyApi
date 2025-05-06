namespace :db do
  desc "Fix duplicate slugs in posts table"
  task fix_duplicate_slugs: :environment do
    connection = ActiveRecord::Base.connection
    
    puts "Checking for duplicate slugs..."
    
    # Find duplicate slugs
    duplicate_slugs = connection.execute("
      SELECT slug, COUNT(*) as count, array_agg(id) as post_ids
      FROM posts
      WHERE slug IS NOT NULL
      GROUP BY slug
      HAVING COUNT(*) > 1
    ")
    
    if duplicate_slugs.count > 0
      puts "Found duplicate slugs in posts table:"
      
      duplicate_slugs.each do |row|
        slug = row['slug']
        count = row['count']
        post_ids = row['post_ids'].tr('{}', '').split(',').map(&:to_i)
        
        puts "  - '#{slug}' appears #{count} times (post IDs: #{post_ids.join(', ')})"
        
        # Keep the first occurrence as is, update others with a suffix
        post_ids.shift # Remove the first ID (we'll keep this one unchanged)
        
        post_ids.each do |id|
          new_slug = "#{slug}-#{id}"
          connection.execute("UPDATE posts SET slug = '#{new_slug}' WHERE id = #{id}")
          puts "    - Updated post ID #{id} with new slug '#{new_slug}'"
        end
      end
      
      puts "All duplicate slugs have been fixed."
    else
      puts "No duplicate slugs found in posts table."
    end
    
    puts "Attempting to add unique indexes..."
    
    # Try to add indexes one by one
    begin
      connection.execute("CREATE UNIQUE INDEX IF NOT EXISTS index_communities_on_slug ON communities (slug)")
      puts "Successfully added unique index on communities.slug"
    rescue => e
      puts "Error adding index to communities.slug: #{e.message}"
    end
    
    begin
      connection.execute("CREATE UNIQUE INDEX IF NOT EXISTS index_posts_on_slug ON posts (slug)")
      puts "Successfully added unique index on posts.slug"
    rescue => e
      puts "Error adding index to posts.slug: #{e.message}"
    end
    
    begin
      connection.execute("CREATE UNIQUE INDEX IF NOT EXISTS index_posts_on_public_id ON posts (public_id)")
      puts "Successfully added unique index on posts.public_id"
    rescue => e
      puts "Error adding index to posts.public_id: #{e.message}"
    end
    
    begin
      connection.execute("CREATE UNIQUE INDEX IF NOT EXISTS index_comments_on_public_id ON comments (public_id)")
      puts "Successfully added unique index on comments.public_id"
    rescue => e
      puts "Error adding index to comments.public_id: #{e.message}"
    end
  end
end 