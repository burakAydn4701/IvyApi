class AddImageUrlsToCommunities < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :profile_picture_url, :string
    add_column :communities, :banner_url, :string
  end
end 