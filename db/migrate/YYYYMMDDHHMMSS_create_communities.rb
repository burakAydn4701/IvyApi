class CreateCommunities < ActiveRecord::Migration[7.0]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.text :description
      t.string :profile_photo
      t.string :banner

      t.timestamps
    end

    add_index :communities, :name, unique: true
  end
end 