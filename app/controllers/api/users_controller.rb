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
        if params[:user] && params[:user][:profile_photo].present?
          # Handle file upload from FormData
          Rails.logger.info "Received file upload via FormData"
          
          result = Cloudinary::Uploader.upload(
            params[:user][:profile_photo], 
            folder: "user_profiles", 
            public_id: "user_#{current_user.id}",
            resource_type: "auto" # Let Cloudinary auto-detect the resource type
          )
          
          if current_user.update(profile_photo_url: result['secure_url'])
            render json: { success: true, profile_photo_url: current_user.profile_photo_url }
          else
            render json: { success: false, errors: current_user.errors.full_messages }, status: :unprocessable_entity
          end
        elsif params[:profile_photo_base64].present?
          # Log the first few characters of the base64 string for debugging
          Rails.logger.info "Received base64 string (first 30 chars): #{params[:profile_photo_base64][0..30]}"
          
          # Extract the image format from the base64 string if it contains the format info
          base64_data = params[:profile_photo_base64].to_s.strip
          
          # Validate the base64 string format
          if base64_data.start_with?('data:image')
            # The string already has the data URI format
            upload_data = base64_data
          else
            # Check if it's a valid base64 string
            # Remove any whitespace that might cause issues
            cleaned_base64 = base64_data.gsub(/\s+/, '')
            
            # Try to decode the base64 string to validate it
            begin
              Base64.strict_decode64(cleaned_base64)
              # If we get here, it's valid base64
              upload_data = "data:image/png;base64,#{cleaned_base64}"
            rescue ArgumentError => e
              Rails.logger.error "Invalid base64 string: #{e.message}"
              return render json: { success: false, message: "Invalid image data format" }, status: :bad_request
            end
          end
          
          # Try to upload to Cloudinary
          result = Cloudinary::Uploader.upload(
            upload_data, 
            folder: "user_profiles", 
            public_id: "user_#{current_user.id}",
            resource_type: "auto" # Let Cloudinary auto-detect the resource type
          )
          
          if current_user.update(profile_photo_url: result['secure_url'])
            render json: { success: true, profile_photo_url: current_user.profile_photo_url }
          else
            render json: { success: false, errors: current_user.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { success: false, message: "No profile photo provided" }, status: :bad_request
        end
      rescue Cloudinary::Api::Error => e
        Rails.logger.error "Cloudinary API Error: #{e.message}"
        render json: { success: false, message: "Image upload failed: #{e.message}" }, status: :unprocessable_entity
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