# app/controllers/api/communities_controller.rb
module Api
  class CommunitiesController < ApplicationController
    # GET /api/communities
    def index
      @communities = Community.all
      render json: @communities
    end

    # GET /api/communities/:id
    def show
      @community = Community.find(params[:id])
      
      render json: @community
    end

    # POST /api/communities
    def create
      Rails.logger.info "Starting community creation..."
      Rails.logger.info "Params: #{params.inspect}"
      
      @community = Community.new(community_params)
      
      begin
        if params[:community][:profile_photo].present?
          Rails.logger.info "Attempting to attach profile photo..."
          @community.attach_profile_picture(params[:community][:profile_photo])
        end
        
        if params[:community][:banner].present?
          Rails.logger.info "Attempting to attach banner..."
          @community.attach_banner(params[:community][:banner])
        end

        if @community.save
          Rails.logger.info "Community created successfully!"
          render json: @community, status: :created
        else
          Rails.logger.error "Failed to create community: #{@community.errors.full_messages}"
          render json: { errors: @community.errors.full_messages }, status: :unprocessable_entity
        end
      rescue => e
        Rails.logger.error "Error creating community: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { 
          error: "Failed to create community", 
          message: e.message,
          backtrace: e.backtrace.first(5)
        }, status: :internal_server_error
      end
    end

    # PATCH/PUT /api/communities/:id
    def update
      community = Community.find(params[:id])
      if community.update(community_params)
        render json: community
      else
        render json: community.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/communities/:id
    def destroy
      community = Community.find(params[:id])
      community.destroy
      head :no_content
    end

    def posts
      @community = Community.find(params[:id])
      @posts = @community.posts.includes(:user, :comments)
      
      render json: @posts.as_json(
        include: {
          user: { only: [:id, :username] }
        },
        methods: [:comments_count, :upvotes_count]
      )
    end

    private

    def community_params
      params.require(:community).permit(:name, :description)
    end
  end
end