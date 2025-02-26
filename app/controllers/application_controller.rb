class ApplicationController < ActionController::API
  rescue_from StandardError do |e|
    Rails.logger.error "Application Error: #{e.class} - #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    
    render json: {
      error: e.class.to_s,
      message: e.message,
      backtrace: e.backtrace.first(5)
    }, status: :internal_server_error
  end

  private

  def authenticate_user
    render json: { error: "You need to be logged in to perform this action" }, status: :unauthorized unless current_user
  end

  def current_user
    if decoded_token
      @current_user ||= User.find_by(id: decoded_token['user_id'])
    end
  end

  def decoded_token
    if request.headers['Authorization']
      token = request.headers['Authorization'].split(' ')[1]
      begin
        decoded = JWT.decode(token, ENV['JWT_SECRET'])[0]
        Rails.logger.debug "JWT_SECRET: #{ENV['JWT_SECRET']}"  # Log the JWT secret
        Rails.logger.debug "Decoded Token: #{decoded}"  # Log the decoded token
        decoded
      rescue JWT::DecodeError
        nil
      end
    end
  end
end
