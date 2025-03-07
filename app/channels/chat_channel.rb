class ChatChannel < ApplicationCable::Channel
  def subscribed
    if params[:chat_id].present?
      chat = Chat.find(params[:chat_id])
      if chat.participants.include?(current_user)
        stream_from "chat_#{params[:chat_id]}"
        logger.info "User #{current_user.id} subscribed to chat #{params[:chat_id]}"
      else
        logger.error "User #{current_user.id} attempted to subscribe to unauthorized chat #{params[:chat_id]}"
        reject
      end
    end
  end

  def unsubscribed
    stop_all_streams
    logger.info "User #{current_user.id} unsubscribed from chat"
  end

  def receive(data)
    begin
      chat = Chat.find(params[:chat_id])
      return unless chat.participants.include?(current_user)

      message = chat.messages.create!(
        user: current_user,
        body: data['message']
      )

      broadcast_message(message)
    rescue => e
      logger.error "Error in ChatChannel#receive: #{e.message}"
      logger.error e.backtrace.join("\n")
    end
  end

  private

  def broadcast_message(message)
    ActionCable.server.broadcast(
      "chat_#{params[:chat_id]}", 
      {
        id: message.id,
        body: message.body,
        created_at: message.created_at,
        user: {
          id: message.user.id,
          username: message.user.username,
          profile_photo_url: message.user.profile_photo_url
        }
      }
    )
  end
end 