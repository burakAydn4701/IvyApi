class PopulateSlugsAndPublicIdsSimple < ActiveRecord::Migration[7.1]
  def up
    # Generate slugs for communities
    execute <<-SQL
      UPDATE communities
      SET slug = LOWER(REPLACE(REPLACE(name, ' ', '-'), '.', '-'))
      WHERE slug IS NULL OR slug = ''
    SQL

    # Generate slugs for posts
    execute <<-SQL
      UPDATE posts
      SET slug = LOWER(REPLACE(REPLACE(title, ' ', '-'), '.', '-'))
      WHERE slug IS NULL OR slug = ''
    SQL

    # Generate public_ids for posts
    execute <<-SQL
      UPDATE posts
      SET public_id = SUBSTRING(MD5(RANDOM()::text), 1, 10)
      WHERE public_id IS NULL OR public_id = ''
    SQL

    # Generate public_ids for comments
    execute <<-SQL
      UPDATE comments
      SET public_id = SUBSTRING(MD5(RANDOM()::text), 1, 10)
      WHERE public_id IS NULL OR public_id = ''
    SQL
  end
end 