module Api
  class UsersController < ApplicationController
    before_action :authenticate_user, except: [:index, :show, :create]

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
        # Log what parameters we're receiving
        Rails.logger.info "Profile photo update params: #{params.to_json}"
        
        # Check all possible parameter locations
        if params[:profile_photo].present?
          # Same parameter name as in the regular update method
          photo_param = params[:profile_photo]
          Rails.logger.info "Found profile_photo parameter"
        elsif params[:user] && params[:user][:profile_photo].present?
          # Nested under user, like in post creation
          photo_param = params[:user][:profile_photo]
          Rails.logger.info "Found user[profile_photo] parameter"
        elsif params[:profile_photo_base64].present?
          # Base64 format
          base64_data = params[:profile_photo_base64].to_s.strip
          Rails.logger.info "Found profile_photo_base64 parameter"
          
          # Process base64 data
          if base64_data.start_with?('data:image')
            upload_data = base64_data
          else
            upload_data = "data:image/png;base64,#{base64_data.gsub(/\s+/, '')}"
          end
          
          # Upload to Cloudinary
          result = Cloudinary::Uploader.upload(
            upload_data, 
            folder: "user_profiles", 
            public_id: "user_#{current_user.id}",
            resource_type: "auto"
          )
          
          if current_user.update(profile_photo_url: result['secure_url'])
            render json: { success: true, profile_photo_url: current_user.profile_photo_url }
          else
            render json: { success: false, errors: current_user.errors.full_messages }, status: :unprocessable_entity
          end
          return
        else
          render json: { success: false, message: "No profile photo provided" }, status: :bad_request
          return
        end
        
        # Handle file upload (for non-base64 cases)
        Rails.logger.info "Uploading file to Cloudinary"
        result = Cloudinary::Uploader.upload(
          photo_param, 
          folder: "user_profiles", 
          public_id: "user_#{current_user.id}",
          resource_type: "auto"
        )
        
        if current_user.update(profile_photo_url: result['secure_url'])
          render json: { success: true, profile_photo_url: current_user.profile_photo_url }
        else
          render json: { success: false, errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "Error uploading to Cloudinary: #{e.class.name} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { success: false, message: "Server error: #{e.message}" }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation, :profile_photo)
    end
  end
end 