class ChatChannel < ApplicationCable::Channel
  def subscribed
    chat = Chat.find(params[:chat_id])
    
    # Check if user is part of the chat
    if chat.sender_id == current_user.id || chat.recipient_id == current_user.id
      stream_from "chat_#{params[:chat_id]}"
    else
      reject
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end 