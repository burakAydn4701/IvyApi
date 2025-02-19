class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  has_many :comments
  has_many :upvotes, as: :voteable
  
  validates :title, presence: true
  validates :content, presence: true
end
