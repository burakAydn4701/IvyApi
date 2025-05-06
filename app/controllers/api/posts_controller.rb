module Api
  class PostsController < ApplicationController
    before_action :authenticate_user, except: [:index, :show, :user_posts]
    before_action :set_post, only: [:show, :update, :destroy, :upvote]
    before_action :authorize_user, only: [:update, :destroy]

    def index
      @posts = Post.includes(:user, :community, :upvotes).order(created_at: :desc)
      
      render json: @posts.map { |post| post_with_metadata(post) }
    end

    def show
      render json: post_with_metadata(@post)
    end

    def user_posts
      user = User.find(params[:user_id])
      @posts = user.posts.includes(:community, :upvotes).order(created_at: :desc)
      
      render json: @posts.map { |post| post_with_metadata(post) }
    rescue => e
      Rails.logger.error "Error in user_posts: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: e.class.name, message: e.message }, status: :internal_server_error
    end

    def create
      @post = current_user.posts.new(post_params.except(:image))
      
      # Handle image upload if present
      if params[:post] && params[:post][:image].present?
        @post.attach_image(params[:post][:image])
      end
      
      if @post.save
        render json: post_with_metadata(@post), status: :created
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      # Handle image update if present
      if params[:post] && params[:post][:image].present?
        @post.attach_image(params[:post][:image])
      end
      
      if @post.update(post_params.except(:image))
        render json: post_with_metadata(@post)
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy
      head :no_content
    end

    def upvote
      if @post.upvotes.where(user: current_user).exists?
        render json: { error: "Already upvoted" }, status: :unprocessable_entity
      else
        @post.upvotes.create(user: current_user)
        render json: post_with_metadata(@post), status: :ok
      end
    end

    private

    def set_post
      id_or_slug = params[:id].to_s.split('-').first
      @post = Post.includes(:user, :community, :upvotes)
                 .find_by!(public_id: id_or_slug)
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

    def post_with_metadata(post)
      {
        id: post.id,
        public_id: post.public_id,
        slug: post.slug,
        url: "/#{post.community.slug}/#{post.to_param}",
        title: post.title,
        content: post.content,
        created_at: post.created_at,
        updated_at: post.updated_at,
        image_url: post.image_url,
        user: {
          id: post.user.id,
          username: post.user.username,
          profile_photo_url: post.user.profile_photo_url
        },
        community: post.community ? {
          id: post.community.id,
          name: post.community.name,
          slug: post.community.slug
        } : nil,
        comments_count: post.comments.count,
        upvotes_count: post.upvotes.size,
        upvoted_by_current_user: current_user ? post.upvotes.exists?(user_id: current_user.id) : false
      }
    end
  end
end 