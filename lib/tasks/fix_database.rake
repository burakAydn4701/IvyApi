namespace :db do
  desc "Check and fix database issues"
  task fix_database: :environment do
    connection = ActiveRecord::Base.connection
    
    puts "Checking database schema..."
    
    # Check if columns exist
    tables_columns = {
      'communities' => ['slug'],
      'posts' => ['slug', 'public_id'],
      'comments' => ['public_id']
    }
    
    missing_columns = {}
    
    tables_columns.each do |table, columns|
      existing_columns = connection.execute("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = '#{table}'
      ").map { |row| row['column_name'] }
      
      puts "#{table} columns: #{existing_columns.join(', ')}"
      
      missing = columns - existing_columns
      if missing.any?
        missing_columns[table] = missing
        puts "Missing columns in #{table}: #{missing.join(', ')}"
      else
        puts "All required columns exist in #{table}"
      end
    end
    
    # Add missing columns if any
    if missing_columns.any?
      puts "Adding missing columns..."
      
      missing_columns.each do |table, columns|
        columns.each do |column|
          begin
            connection.execute("ALTER TABLE #{table} ADD COLUMN #{column} VARCHAR;")
            puts "Added column #{column} to #{table}"
          rescue => e
            puts "Error adding column #{column} to #{table}: #{e.message}"
          end
        end
      end
    end
    
    # Populate missing values
    puts "Populating missing values..."
    
    # Generate slugs for communities
    connection.execute("
      UPDATE communities
      SET slug = LOWER(REPLACE(REPLACE(name, ' ', '-'), '.', '-'))
      WHERE slug IS NULL OR slug = '';
    ")
    puts "Generated slugs for communities"
    
    # Generate slugs for posts
    connection.execute("
      UPDATE posts
      SET slug = LOWER(REPLACE(REPLACE(title, ' ', '-'), '.', '-'))
      WHERE slug IS NULL OR slug = '';
    ")
    puts "Generated slugs for posts"
    
    # Generate random public_ids for posts
    connection.execute("
      UPDATE posts
      SET public_id = SUBSTRING(MD5(RANDOM()::text), 1, 10)
      WHERE public_id IS NULL OR public_id = '';
    ")
    puts "Generated public_ids for posts"
    
    # Generate random public_ids for comments
    connection.execute("
      UPDATE comments
      SET public_id = SUBSTRING(MD5(RANDOM()::text), 1, 10)
      WHERE public_id IS NULL OR public_id = '';
    ")
    puts "Generated public_ids for comments"
    
    # Check for duplicate slugs
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
        
        # Fix duplicates by appending ID to all but the first occurrence
        first_id = post_ids.min
        post_ids.delete(first_id)
        
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
    
    # Check existing indexes
    indexes = connection.execute("
      SELECT indexname, tablename
      FROM pg_indexes
      WHERE tablename IN ('communities', 'posts', 'comments')
    ")
    
    puts "Existing indexes:"
    if indexes.count > 0
      indexes.each do |row|
        puts "  - #{row['tablename']}.#{row['indexname']}"
      end
    else
      puts "  - No indexes found"
    end
    
    # Add missing indexes
    puts "Adding missing indexes..."
    
    indexes_to_add = {
      'communities' => [{ name: 'index_communities_on_slug', columns: 'slug', unique: true }],
      'posts' => [
        { name: 'index_posts_on_slug', columns: 'slug', unique: true },
        { name: 'index_posts_on_public_id', columns: 'public_id', unique: true }
      ],
      'comments' => [{ name: 'index_comments_on_public_id', columns: 'public_id', unique: true }]
    }
    
    indexes_to_add.each do |table, idx_list|
      idx_list.each do |idx|
        begin
          unique_clause = idx[:unique] ? 'UNIQUE' : ''
          connection.execute("CREATE #{unique_clause} INDEX IF NOT EXISTS #{idx[:name]} ON #{table} (#{idx[:columns]});")
          puts "Added index #{idx[:name]} to #{table}"
        rescue => e
          puts "Error adding index #{idx[:name]} to #{table}: #{e.message}"
        end
      end
    end
    
    puts "Database check and fix completed."
  end
end 