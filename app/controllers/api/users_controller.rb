module Api
  class UsersController < ApplicationController
    def index
      @users = User.all
      render json: @users
    end

    def show
      @user = User.find(params[:id])
      render json: @user
    end

    def create
      @user = User.new(user_params)
      
      if @user.save
        render json: @user, status: :created
      else
        render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if params[:profile_photo].present?
        # Upload to Cloudinary
        result = Cloudinary::Uploader.upload(params[:profile_photo], 
          folder: "user_profiles", 
          public_id: "user_#{current_user.id}")
        
        # Update user with the Cloudinary URL
        current_user.update(profile_photo_url: result['secure_url'])
      end
      
      # ... rest of update method ...
    end

    def update_profile_photo
      begin
        if params[:profile_photo_base64].present?
          # Log the first few characters of the base64 string for debugging
          Rails.logger.info "Received base64 string (first 30 chars): #{params[:profile_photo_base64][0..30]}"
          
          # Try to upload to Cloudinary
          result = Cloudinary::Uploader.upload(
            "data:image/png;base64,#{params[:profile_photo_base64]}", 
            folder: "user_profiles", 
            public_id: "user_#{current_user.id}"
          )
          
          if current_user.update(profile_photo_url: result['secure_url'])
            render json: { success: true, profile_photo_url: current_user.profile_photo_url }
          else
            render json: { success: false, errors: current_user.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { success: false, message: "No profile photo provided" }, status: :bad_request
        end
      rescue => e
        Rails.logger.error "Error uploading to Cloudinary: #{e.message}"
        render json: { success: false, message: e.message }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :profile_photo)
    end
  end
end 