class CreateUpvotes < ActiveRecord::Migration[8.0]
  def change
    create_table :upvotes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :voteable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
