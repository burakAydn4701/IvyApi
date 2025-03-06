module Api
  class MessagesController < ApplicationController
    before_action :authenticate_user
    before_action :set_chat
    
    def create
      @message = @chat.messages.new(message_params)
      @message.user = current_user
      
      if @message.save
        message_data = {
          id: @message.id,
          body: @message.body,
          user_id: @message.user_id,
          created_at: @message.created_at,
          message_time: @message.message_time,
          is_mine: false # Will be true for the sender, false for the recipient
        }
        
        # Broadcast the message to the chat channel
        ActionCable.server.broadcast(
          "chat_#{@chat.id}",
          message_data
        )
        
        # Return the message with is_mine set to true for the sender
        message_data[:is_mine] = true
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