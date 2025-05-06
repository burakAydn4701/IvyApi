namespace :db do
  desc "Check if slug and public_id columns exist in the database"
  task check_columns: :environment do
    connection = ActiveRecord::Base.connection
    
    puts "Checking database schema..."
    
    # Check communities table
    communities_columns = connection.columns('communities').map(&:name)
    puts "Communities columns: #{communities_columns.join(', ')}"
    puts "Has slug column: #{communities_columns.include?('slug')}"
    
    # Check posts table
    posts_columns = connection.columns('posts').map(&:name)
    puts "Posts columns: #{posts_columns.join(', ')}"
    puts "Has slug column: #{posts_columns.include?('slug')}"
    puts "Has public_id column: #{posts_columns.include?('public_id')}"
    
    # Check comments table
    comments_columns = connection.columns('comments').map(&:name)
    puts "Comments columns: #{comments_columns.join(', ')}"
    puts "Has public_id column: #{comments_columns.include?('public_id')}"
    
    # Check if friendly_id_slugs table exists
    tables = connection.tables
    puts "Tables in database: #{tables.join(', ')}"
    puts "Has friendly_id_slugs table: #{tables.include?('friendly_id_slugs')}"
    
    if tables.include?('friendly_id_slugs')
      slugs_count = connection.select_value("SELECT COUNT(*) FROM friendly_id_slugs")
      puts "Number of records in friendly_id_slugs: #{slugs_count}"
    end
    
    # Check for duplicate slugs in posts
    if posts_columns.include?('slug')
      duplicate_slugs = connection.select_all("
        SELECT slug, COUNT(*) as count
        FROM posts
        WHERE slug IS NOT NULL
        GROUP BY slug
        HAVING COUNT(*) > 1
      ")
      
      if duplicate_slugs.any?
        puts "Found duplicate slugs in posts table:"
        duplicate_slugs.each do |row|
          puts "  - '#{row['slug']}' appears #{row['count']} times"
        end
      else
        puts "No duplicate slugs found in posts table."
      end
    end
    
    # Check for null values
    if posts_columns.include?('slug')
      null_slugs = connection.select_value("SELECT COUNT(*) FROM posts WHERE slug IS NULL")
      puts "Posts with NULL slug: #{null_slugs}"
    end
    
    if posts_columns.include?('public_id')
      null_public_ids = connection.select_value("SELECT COUNT(*) FROM posts WHERE public_id IS NULL")
      puts "Posts with NULL public_id: #{null_public_ids}"
    end
  end
end 