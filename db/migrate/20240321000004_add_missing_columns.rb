class AddMissingColumns < ActiveRecord::Migration[7.1]
  def up
    # Use direct SQL to add columns if they don't exist
    execute <<-SQL
      DO $$
      BEGIN
        -- Add slug column to communities if it doesn't exist
        IF NOT EXISTS (
          SELECT 1
          FROM information_schema.columns
          WHERE table_name = 'communities' AND column_name = 'slug'
        ) THEN
          ALTER TABLE communities ADD COLUMN slug VARCHAR;
        END IF;

        -- Add slug column to posts if it doesn't exist
        IF NOT EXISTS (
          SELECT 1
          FROM information_schema.columns
          WHERE table_name = 'posts' AND column_name = 'slug'
        ) THEN
          ALTER TABLE posts ADD COLUMN slug VARCHAR;
        END IF;

        -- Add public_id column to posts if it doesn't exist
        IF NOT EXISTS (
          SELECT 1
          FROM information_schema.columns
          WHERE table_name = 'posts' AND column_name = 'public_id'
        ) THEN
          ALTER TABLE posts ADD COLUMN public_id VARCHAR;
        END IF;

        -- Add public_id column to comments if it doesn't exist
        IF NOT EXISTS (
          SELECT 1
          FROM information_schema.columns
          WHERE table_name = 'comments' AND column_name = 'public_id'
        ) THEN
          ALTER TABLE comments ADD COLUMN public_id VARCHAR;
        END IF;
      END
      $$;
    SQL

    # Populate data
    execute <<-SQL
      -- Generate random public_ids for posts
      UPDATE posts
      SET public_id = SUBSTRING(MD5(RANDOM()::text), 1, 10)
      WHERE public_id IS NULL;

      -- Generate random public_ids for comments
      UPDATE comments
      SET public_id = SUBSTRING(MD5(RANDOM()::text), 1, 10)
      WHERE public_id IS NULL;

      -- Generate slugs for posts
      UPDATE posts
      SET slug = LOWER(REPLACE(REPLACE(title, ' ', '-'), '.', '-'))
      WHERE slug IS NULL;

      -- Generate slugs for communities
      UPDATE communities
      SET slug = LOWER(REPLACE(REPLACE(name, ' ', '-'), '.', '-'))
      WHERE slug IS NULL;
    SQL

    # Add indexes
    execute <<-SQL
      DO $$
      BEGIN
        -- Add index on communities.slug if it doesn't exist
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE tablename = 'communities' AND indexname = 'index_communities_on_slug'
        ) THEN
          CREATE UNIQUE INDEX index_communities_on_slug ON communities (slug);
        END IF;

        -- Add index on posts.slug if it doesn't exist
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE tablename = 'posts' AND indexname = 'index_posts_on_slug'
        ) THEN
          CREATE UNIQUE INDEX index_posts_on_slug ON posts (slug);
        END IF;

        -- Add index on posts.public_id if it doesn't exist
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE tablename = 'posts' AND indexname = 'index_posts_on_public_id'
        ) THEN
          CREATE UNIQUE INDEX index_posts_on_public_id ON posts (public_id);
        END IF;

        -- Add index on comments.public_id if it doesn't exist
        IF NOT EXISTS (
          SELECT 1
          FROM pg_indexes
          WHERE tablename = 'comments' AND indexname = 'index_comments_on_public_id'
        ) THEN
          CREATE UNIQUE INDEX index_comments_on_public_id ON comments (public_id);
        END IF;
      END
      $$;
    SQL
  end

  def down
    # Remove indexes
    execute <<-SQL
      DROP INDEX IF EXISTS index_communities_on_slug;
      DROP INDEX IF EXISTS index_posts_on_slug;
      DROP INDEX IF EXISTS index_posts_on_public_id;
      DROP INDEX IF EXISTS index_comments_on_public_id;
    SQL

    # Remove columns
    execute <<-SQL
      ALTER TABLE communities DROP COLUMN IF EXISTS slug;
      ALTER TABLE posts DROP COLUMN IF EXISTS slug;
      ALTER TABLE posts DROP COLUMN IF EXISTS public_id;
      ALTER TABLE comments DROP COLUMN IF EXISTS public_id;
    SQL
  end
end 