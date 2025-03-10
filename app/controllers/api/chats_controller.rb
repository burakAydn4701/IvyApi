module Api
  class ChatsController < ApplicationController
    before_action :authenticate_user
    before_action :set_chat, only: [:show]
    
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
      # Check if user is part of the chat
      unless @chat.sender_id == current_user.id || @chat.recipient_id == current_user.id
        return render json: { error: "Not authorized to view this chat" }, status: :unauthorized
      end
      
      opposed_user = @chat.opposed_user(current_user)
      
      # Mark messages as read
      @chat.messages.where.not(user_id: current_user.id).update_all(read: true)
      
      render json: {
        chat: {
          id: @chat.id,
          opposed_user: {
            id: opposed_user.id,
            username: opposed_user.username,
            profile_photo_url: opposed_user.profile_photo_url
          }
        },
        messages: @chat.messages.order(created_at: :asc).map { |message|
          {
            id: message.id,
            body: message.body,
            user_id: message.user_id,
            created_at: message.created_at,
            read: message.read
          }
        }
      }
    end
    
    def create
      recipient_id = params[:recipient_id]
      
      # Validate recipient exists
      recipient = User.find_by(id: recipient_id)
      unless recipient
        return render json: { error: "Recipient not found" }, status: :not_found
      end
      
      # Check if chat already exists between these users
      existing_chat = Chat.where(sender_id: current_user.id, recipient_id: recipient_id)
                          .or(Chat.where(sender_id: recipient_id, recipient_id: current_user.id))
                          .first
      
      if existing_chat
        # Return the existing chat
        opposed_user = existing_chat.opposed_user(current_user)
        
        return render json: {
          id: existing_chat.id,
          opposed_user: {
            id: opposed_user.id,
            username: opposed_user.username,
            profile_photo_url: opposed_user.profile_photo_url
          },
          created_at: existing_chat.created_at,
          updated_at: existing_chat.updated_at
        }
      end
      
      # Create a new chat
      @chat = Chat.new(sender_id: current_user.id, recipient_id: recipient_id)
      
      if @chat.save
        render json: {
          id: @chat.id,
          opposed_user: {
            id: recipient.id,
            username: recipient.username,
            profile_photo_url: recipient.profile_photo_url
          },
          created_at: @chat.created_at,
          updated_at: @chat.updated_at
        }, status: :created
      else
        render json: { errors: @chat.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_chat
      @chat = Chat.find(params[:id])
    end
  end
end 