class AddProfilePhotoUrlToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :profile_photo_url, :string
  end
end
