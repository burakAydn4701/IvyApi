module Api
  class ChatsController < ApplicationController
    before_action :authenticate_user
    
    def index
      @chats = current_user.chats
      
      render json: @chats.map { |chat|
        opposed_user = chat.opposed_user(current_user)
        {
          id: chat.id,
          opposed_user: {
            id: opposed_user.id,
            username: opposed_user.username,
            profile_photo_url: opposed_user.profile_photo_url
          },
          last_message: chat.messages.order(created_at: :desc).first&.body,
          unread_count: chat.messages.where.not(user_id: current_user.id).where(read: false).count,
          updated_at: chat.updated_at
        }
      }
    end
    
    def show
      @chat = Chat.find(params[:id])
      
      # Check if user is part of the chat
      unless @chat.sender_id == current_user.id || @chat.recipient_id == current_user.id
        return render json: { error: "Not authorized to view this chat" }, status: :unauthorized
      end
      
      @opposed_user = @chat.opposed_user(current_user)
      @messages = @chat.messages.order(created_at: :asc)
      
      # Mark messages as read
      @chat.messages.where.not(user_id: current_user.id).update_all(read: true)
      
      render json: {
        chat: {
          id: @chat.id,
          opposed_user: {
            id: @opposed_user.id,
            username: @opposed_user.username,
            profile_photo_url: @opposed_user.profile_photo_url
          }
        },
        messages: @messages.map { |message|
          {
            id: message.id,
            body: message.body,
            user_id: message.user_id,
            created_at: message.created_at,
            message_time: message.message_time,
            is_mine: message.user_id == current_user.id
          }
        }
      }
    end
    
    def create
      recipient_id = params[:recipient_id]
      
      if recipient_id == current_user.id
        return render json: { error: "Cannot start a chat with yourself" }, status: :unprocessable_entity
      end
      
      @chat = Chat.get(current_user.id, recipient_id)
      
      render json: { chat_id: @chat.id }, status: :created
    end
  end
end 