module Api
  class PostsController < ApplicationController
    before_action :authenticate_user!

    def index
      @posts = if params[:community_id]
        Community.find(params[:community_id]).posts
      else
        Post.all
      end
      render json: @posts
    end

    def show
      @post = Post.find(params[:id])
      render json: @post
    end

    def create
      @post = Post.new(post_params)
      @post.attach_image(params[:post][:image]) if params[:post][:image].present?
      
      if @post.save
        render json: @post, status: :created
      else
        render json: { error: @post.errors.full_messages }, status: :unprocessable_entity
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

    private

    def post_params
      params.require(:post).permit(:title, :content, :user_id, :community_id)
    end
  end
end 