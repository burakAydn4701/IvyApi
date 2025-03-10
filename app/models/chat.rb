class Chat < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User'
  
  has_many :messages, dependent: :destroy
  
  validates :sender_id, uniqueness: { scope: :recipient_id }
  
  scope :between, -> (sender_id, recipient_id) do
    where(sender_id: sender_id, recipient_id: recipient_id).or(
      where(sender_id: recipient_id, recipient_id: sender_id)
    )
  end
  
  def self.get(sender_id, recipient_id)
    chat = between(sender_id, recipient_id).first
    
    if chat.blank?
      chat = create(sender_id: sender_id, recipient_id: recipient_id)
    end
    
    chat
  end
  
  def participants
    [sender, recipient]
  end
  
  def opposed_user(current_user)
    current_user.id == sender_id ? recipient : sender
  end
end 