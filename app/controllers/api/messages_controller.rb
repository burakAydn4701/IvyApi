module Api
  class MessagesController < ApplicationController
    before_action :authenticate_user
    before_action :set_chat
    
    def create
      @message = @chat.messages.new(message_params)
      @message.user = current_user
      
      if @message.save
        # Format the message in a consistent way with ChatChannel
        message_data = {
          id: @message.id,
          body: @message.body,
          created_at: @message.created_at,
          user: {
            id: current_user.id,
            username: current_user.username,
            profile_photo_url: current_user.profile_photo_url
          }
        }
        
        # Broadcast the message to the chat channel
        ActionCable.server.broadcast(
          "chat_#{@chat.id}",
          message_data
        )
        
        # Return the same format to the sender
        render json: message_data, status: :created
      else
        render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
      end
    end
    
    private
    
    def set_chat
      @chat = Chat.find(params[:chat_id])
      
      # Check if user is part of the chat
      unless @chat.sender_id == current_user.id || @chat.recipient_id == current_user.id
        render json: { error: "Not authorized to access this chat" }, status: :unauthorized
      end
    end
    
    def message_params
      params.require(:message).permit(:body)
    end
  end
end