class CreateCommunities < ActiveRecord::Migration[8.0]
  def change
    create_table :communities do |t|
      t.string :name
      t.string :profile_photo
      t.string :banner
      t.text :description

      t.timestamps
    end
  end
end
