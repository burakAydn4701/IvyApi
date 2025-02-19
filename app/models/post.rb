class Post < ApplicationRecord
  belongs_to :user
  belongs_to :community
  
  validates :title, presence: true
  validates :content, presence: true
end
