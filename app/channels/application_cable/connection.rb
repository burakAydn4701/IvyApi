module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.info "WebSocket connected: User ##{current_user.id}" if current_user
    end

    private
    
    def find_verified_user
      token = request.params[:token]
      
      unless token
        logger.error "WebSocket rejected: No token provided"
        return reject_unauthorized_connection
      end

      begin
        # Use the same JWT_SECRET as in the rest of the application
        decoded_token = JWT.decode(token, ENV['JWT_SECRET'])[0]
        user_id = decoded_token['user_id']
        
        user = User.find_by(id: user_id)
        if user
          logger.info "WebSocket authenticated: User ##{user.id}"
          return user
        else
          logger.error "WebSocket rejected: User not found with ID #{user_id}"
          reject_unauthorized_connection
        end
      rescue JWT::DecodeError => e
        logger.error "WebSocket rejected: JWT decode error - #{e.message}"
        reject_unauthorized_connection
      end
    end

    def disconnect
      logger.info "WebSocket disconnected: User ##{current_user&.id}" if current_user
    end
  end
end 