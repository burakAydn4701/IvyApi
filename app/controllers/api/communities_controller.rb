# app/controllers/api/communities_controller.rb
module Api
  class CommunitiesController < ApplicationController
    before_action :authenticate_user, except: [:index, :show]
    before_action :set_community, only: [:show, :update, :destroy]
    before_action :authorize_user, only: [:update, :destroy]

    # GET /api/communities
    def index
      @communities = Community.all
      render json: @communities
    end

    # GET /api/communities/:id
    def show
      render json: @community
    end

    # POST /api/communities
    def create
      @community = current_user.communities.build(community_params)
      
      if @community.save
        render json: @community, status: :created
      else
        render json: { errors: @community.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/communities/:id
    def update
      if @community.update(community_params)
        render json: @community
      else
        render json: { errors: @community.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/communities/:id
    def destroy
      @community.destroy
      head :no_content
    end

    def posts
      @community = Community.find(params[:id])
      @posts = Post.where(community_id: params[:id])
                   .includes(:user, :comments)
                   .order(created_at: :desc)
      
      render json: @posts.as_json(
        include: {
          user: { only: [:id, :username] },
          community: { only: [:id, :name] }
        },
        methods: [:comments_count, :upvotes_count]
      )
    end

    def user_communities
      @communities = current_user.communities
      render json: @communities
    end

    private

    def set_community
      @community = Community.friendly.find(params[:id])
    end

    def authorize_user
      unless @community.user_id == current_user.id
        render json: { error: "Not authorized to modify this community" }, status: :unauthorized
      end
    end

    def community_params
      params.require(:community).permit(:name, :description, :profile_photo, :banner)
    end
  end
end