module Api
  class PostsController < ApplicationController
    before_action :authenticate_user, except: [:index, :show]

    def index
      @posts = Post.all.includes(:community, :user, :comments)
      
      render json: @posts.as_json(
        include: {
          community: { only: [:id, :name] },
          user: { only: [:id, :username] }
        },
        methods: [:comments_count, :upvotes_count]
      )
    end

    def show
      @post = Post.includes(:user, :community).find(params[:id])
      render json: @post.as_json(
        include: {
          community: { only: [:id, :name] },
          user: { only: [:id, :username] }
        },
        methods: [:comments_count, :upvotes_count]
      )
    end

    def create
      @post = Post.new(post_params)
      @post.attach_image(params[:post][:image]) if params[:post][:image].present?
      
      if @post.save
        render json: @post.as_json(methods: :author_name), status: :created
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def upvote
      @post = Post.find(params[:id])
      if @post.upvotes.where(user: current_user).exists?
        render json: { error: "Already upvoted" }, status: :unprocessable_entity
      else
        @post.upvotes.create(user: current_user)
        render json: @post, status: :ok
      end
    end

    def destroy
      @post = Post.find(params[:id])
      
      if @post.destroy
        render json: { message: "Post deleted successfully" }, status: :ok
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def post_params
      params.require(:post).permit(:title, :content, :user_id, :community_id)
    end
  end
end 