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
  
  # Chats where user is the sender
  has_many :sent_chats, class_name: 'Chat', foreign_key: 'sender_id'
  # Chats where user is the recipient
  has_many :received_chats, class_name: 'Chat', foreign_key: 'recipient_id'
  # All messages sent by the user
  has_many :messages
  
  # Get all chats for a user
  def chats
    Chat.where("sender_id = ? OR recipient_id = ?", self.id, self.id)
  end
  
  # Check if user has unread messages
  def has_unread_messages?
    Message.joins(:chat)
           .where("chats.sender_id = ? OR chats.recipient_id = ?", self.id, self.id)
           .where.not(user_id: self.id)
           .where(read: false)
           .exists?
  end
  
  # Count unread messages
  def unread_messages_count
    Message.joins(:chat)
           .where("chats.sender_id = ? OR chats.recipient_id = ?", self.id, self.id)
           .where.not(user_id: self.id)
           .where(read: false)
           .count
  end
end
