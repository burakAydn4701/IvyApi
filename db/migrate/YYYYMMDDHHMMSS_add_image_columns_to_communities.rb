class AddImageColumnsToCommunities < ActiveRecord::Migration[7.0]
  def change
    add_column :communities, :profile_photo, :string
    add_column :communities, :banner, :string
  end
end 