module Api
  class CommentsController < ApplicationController
    before_action :authenticate_user!

    def index
      @comments = if params[:post_id]
        Post.find(params[:post_id]).comments
      else
        Comment.all
      end
      render json: @comments
    end

    def show
      @comment = Comment.find(params[:id])
      render json: @comment
    end

    def create
      @comment = Comment.new(comment_params)
      if @comment.save
        render json: @comment, status: :created
      else
        render json: @comment.errors, status: :unprocessable_entity
      end
    end

    def upvote
      @comment = Comment.find(params[:id])
      if @comment.upvotes.where(user: current_user).exists?
        render json: { error: "Already upvoted" }, status: :unprocessable_entity
      else
        @comment.upvotes.create(user: current_user)
        render json: @comment, status: :ok
      end
    end

    private

    def comment_params
      params.require(:comment).permit(:content, :user_id, :post_id, :parent_id)
    end
  end
end 