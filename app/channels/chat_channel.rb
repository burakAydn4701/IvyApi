class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params[:chat_id].present?
      @chat_id = params[:chat_id]
      @chat = Chat.find(@chat_id)
      
      # Check if current user is part of this chat
      if @chat.sender_id == current_user.id || @chat.recipient_id == current_user.id
        stream_from "chat_#{@chat_id}"
        logger.info "User #{current_user.id} subscribed to chat #{@chat_id}"
      else
        logger.error "User #{current_user.id} attempted to subscribe to unauthorized chat #{@chat_id}"
        reject
      end
    end
  end

  def unsubscribed
    logger.info "User #{current_user.id} unsubscribed from chat #{@chat_id}"
    stop_all_streams
  end

  def receive(data)
    begin
      @chat = Chat.find(params[:chat_id]) unless @chat
      
      # Check if current user is part of this chat
      unless @chat.sender_id == current_user.id || @chat.recipient_id == current_user.id
        logger.error "User #{current_user.id} attempted to send message to unauthorized chat #{@chat_id}"
        return
      end

      message = @chat.messages.create!(
        user: current_user,
        body: data['message']
      )

      # Log the message data for debugging
      logger.info "Message created and broadcasting: #{message.id} - #{message.body}"
      
      broadcast_message(message)
      logger.info "Message broadcast completed for ID #{message.id} in chat #{@chat_id}"
    rescue => e
      logger.error "Error in ChatChannel#receive: #{e.message}"
      logger.error e.backtrace.join("\n")
    end
  end

  private

  def broadcast_message(message)
    # Format the message in a consistent way with MessagesController
    message_data = {
      id: message.id,
      body: message.body,
      created_at: message.created_at,
      user: {
        id: message.user.id,
        username: message.user.username,
        profile_photo_url: message.user.profile_photo_url
      }
    }
    
    # Log the data being broadcast
    logger.info "Broadcasting message data: #{message_data.inspect}"
    
    ActionCable.server.broadcast("chat_#{@chat_id}", message_data)
  end
end 