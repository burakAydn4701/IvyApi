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
end
