class User < ApplicationRecord
  has_many :posts
  has_many :comments
  has_many :upvotes
  has_secure_password
  
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  
  # Add a string field to store the Cloudinary URL
  # If you don't have this column yet, you'll need to create a migration:
  # rails g migration AddProfilePhotoUrlToUsers profile_photo_url:string
end
