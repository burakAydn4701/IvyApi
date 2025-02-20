module Api
  class PostsController < ApplicationController
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
        render json: @post.errors, status: :unprocessable_entity
      end
    end

    private

    def post_params
      params.require(:post).permit(:title, :content, :user_id, :community_id)
    end
  end
end 