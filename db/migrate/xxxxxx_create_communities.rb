class CreateCommunities < ActiveRecord::Migration[6.1]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.string :profile_photo
      t.string :banner
      t.text :description, null: false

      t.timestamps
    end

    add_index :communities, :name, unique: true
  end
end
