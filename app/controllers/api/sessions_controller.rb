module Api
  class SessionsController < ApplicationController
    def create
      # Find user by email or username
      @user = User.find_by(email: params[:email_or_username]) || 
              User.find_by(username: params[:email_or_username])
      
      if @user&.authenticate(params[:password])
        token = encode_token(user_id: @user.id)  # Ensure user_id is included
        render json: { token: token }, status: :ok
      else
        render json: { error: "Invalid credentials" }, status: :unauthorized
      end
    end

    private

    def encode_token(payload)
      JWT.encode(payload, ENV['JWT_SECRET'])  # Ensure you're using the correct secret
    end
  end
end 