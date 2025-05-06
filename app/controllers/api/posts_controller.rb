module Api
  class PostsController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show, :user_posts]
    before_action :set_post, only: [:show, :update, :destroy, :upvote]
    before_action :authorize_user, only: [:update, :destroy]

    def index
      @posts = Post.all.order(created_at: :desc)
      
      render json: @posts
    end

    def show
      render json: @post
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
      @post = Post.new(post_params.except(:image))
      @post.user = current_user

      if params[:image].present?
        @post.attach_image(params[:image])
      end

      if @post.save
        render json: @post, status: :created
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @post.user_id != current_user.id
        return render json: { error: 'You are not authorized to update this post' }, status: :unauthorized
      end

      if @post.update(post_params.except(:image))
        if params[:image].present?
          @post.attach_image(params[:image])
          @post.save
        end
        render json: @post
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      if @post.user_id != current_user.id
        return render json: { error: 'You are not authorized to delete this post' }, status: :unauthorized
      end
      
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
      @post = Post.find_by(id: params[:id]) || Post.find_by(slug: params[:id])
      
      unless @post
        render json: { error: 'Post not found' }, status: :not_found
      end
    end

    def authorize_user
      unless @post.user_id == current_user.id
        render json: { error: "Not authorized to modify this post" }, status: :unauthorized
      end
    end

    def post_params
      params.permit(:title, :content, :community_id, :image)
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