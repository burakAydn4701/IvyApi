namespace :db do
  desc "Check database schema using direct SQL"
  task check_schema: :environment do
    connection = ActiveRecord::Base.connection
    
    puts "Checking database schema using direct SQL..."
    
    # Check if columns exist
    communities_columns = connection.execute("
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'communities'
    ").map { |row| row['column_name'] }
    
    posts_columns = connection.execute("
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'posts'
    ").map { |row| row['column_name'] }
    
    comments_columns = connection.execute("
      SELECT column_name
      FROM information_schema.columns
      WHERE table_name = 'comments'
    ").map { |row| row['column_name'] }
    
    puts "Communities columns: #{communities_columns.join(', ')}"
    puts "Has slug column: #{communities_columns.include?('slug')}"
    
    puts "Posts columns: #{posts_columns.join(', ')}"
    puts "Has slug column: #{posts_columns.include?('slug')}"
    puts "Has public_id column: #{posts_columns.include?('public_id')}"
    
    puts "Comments columns: #{comments_columns.join(', ')}"
    puts "Has public_id column: #{comments_columns.include?('public_id')}"
    
    # Check for duplicate slugs
    if posts_columns.include?('slug')
      duplicate_slugs = connection.execute("
        SELECT slug, COUNT(*) as count
        FROM posts
        WHERE slug IS NOT NULL
        GROUP BY slug
        HAVING COUNT(*) > 1
      ")
      
      if duplicate_slugs.count > 0
        puts "Found duplicate slugs in posts table:"
        duplicate_slugs.each do |row|
          puts "  - '#{row['slug']}' appears #{row['count']} times"
        end
      else
        puts "No duplicate slugs found in posts table."
      end
    end
    
    # Check for existing indexes
    indexes = connection.execute("
      SELECT indexname, tablename
      FROM pg_indexes
      WHERE tablename IN ('communities', 'posts', 'comments')
    ")
    
    puts "Existing indexes:"
    indexes.each do |row|
      puts "  - #{row['tablename']}.#{row['indexname']}"
    end
  end
end 