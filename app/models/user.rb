class User < ApplicationRecord
  has_many :posts
  has_many :comments
  has_many :upvotes
  
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
end
