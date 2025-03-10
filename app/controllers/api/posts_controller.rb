module Api
  class PostsController < ApplicationController
    before_action :authenticate_user, except: [:index, :show, :user_posts]
    before_action :set_post, only: [:show, :update, :destroy]
    before_action :authorize_user, only: [:update, :destroy]

    def index
      @posts = Post.includes(:user, :community).order(created_at: :desc)
      
      render json: @posts.map { |post| post_json(post) }
    end

    def show
      render json: post_json(@post)
    end

    def user_posts
      user = User.find(params[:user_id])
      @posts = user.posts.includes(:community).order(created_at: :desc)
      
      render json: @posts.map { |post| post_json(post) }
    rescue => e
      Rails.logger.error "Error in user_posts: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: e.class.name, message: e.message }, status: :internal_server_error
    end

    def create
      @post = current_user.posts.new(post_params)
      
      if @post.save
        render json: post_json(@post), status: :created
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @post.update(post_params)
        render json: post_json(@post)
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy
      head :no_content
    end

    def upvote
      @post = Post.find(params[:id])
      if @post.upvotes.where(user: current_user).exists?
        render json: { error: "Already upvoted" }, status: :unprocessable_entity
      else
        @post.upvotes.create(user: current_user)
        render json: post_json(@post), status: :ok
      end
    end

    private

    def set_post
      @post = Post.find(params[:id])
    end

    def authorize_user
      unless @post.user_id == current_user.id
        render json: { error: "Not authorized to modify this post" }, status: :unauthorized
      end
    end

    def post_params
      # Use content instead of body since that's what the model has
      params.require(:post).permit(:title, :content, :community_id, :image)
    end

    def post_json(post)
      begin
        json = {
          id: post.id,
          title: post.title,
          content: post.content,
          created_at: post.created_at,
          updated_at: post.updated_at,
          user: {
            id: post.user.id,
            username: post.user.username,
            profile_photo_url: post.user.profile_photo_url
          },
          community: post.community ? {
            id: post.community.id,
            name: post.community.name
          } : nil,
          comments_count: post.comments.count,
          upvotes_count: post.upvotes_count
        }
        
        # Add image URL if present
        json[:image_url] = post.image_url if post.respond_to?(:image_url) && post.image_url.present?
        
        json
      rescue => e
        Rails.logger.error "Error in post_json for post #{post.id}: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        # Return a simplified version if there's an error
        {
          id: post.id,
          title: post.title,
          content: post.content,
          created_at: post.created_at,
          updated_at: post.updated_at,
          error: "Error loading complete post data"
        }
      end
    end
  end
end 