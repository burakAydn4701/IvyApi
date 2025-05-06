module Api
  class CommentsController < ApplicationController
    before_action :authenticate_user, except: [:index, :show]
    before_action :set_comment, only: [:show, :update, :destroy, :upvote]
    before_action :authorize_user, only: [:update, :destroy]

    def index
      post = Post.find_by!(public_id: params[:post_id].to_s.split('-').first)
      @comments = post.comments.includes(:user, :replies).where(parent_id: nil).order(created_at: :desc)
      
      render json: @comments.map { |comment| comment_with_metadata(comment) }
    end

    def show
      render json: comment_with_metadata(@comment)
    end

    def create
      post = Post.find_by!(public_id: params[:post_id].to_s.split('-').first)
      @comment = post.comments.build(comment_params)
      @comment.user = current_user
      
      if @comment.save
        render json: comment_with_metadata(@comment), status: :created
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @comment.update(comment_params)
        render json: comment_with_metadata(@comment)
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @comment.destroy
      head :no_content
    end

    def upvote
      if @comment.upvotes.where(user: current_user).exists?
        render json: { error: "Already upvoted" }, status: :unprocessable_entity
      else
        @comment.upvotes.create(user: current_user)
        render json: comment_with_metadata(@comment), status: :ok
      end
    end

    private

    def set_comment
      @comment = Comment.find_by!(public_id: params[:id])
    end

    def authorize_user
      unless @comment.user_id == current_user.id
        render json: { error: "Not authorized to modify this comment" }, status: :unauthorized
      end
    end

    def comment_params
      params.require(:comment).permit(:content, :parent_id)
    end

    def comment_with_metadata(comment)
      {
        id: comment.id,
        public_id: comment.public_id,
        content: comment.content,
        created_at: comment.created_at,
        updated_at: comment.updated_at,
        user: {
          id: comment.user.id,
          username: comment.user.username,
          profile_photo_url: comment.user.profile_photo_url
        },
        post_id: comment.post.public_id,
        parent_id: comment.parent_id,
        replies_count: comment.replies.size,
        replies: comment.replies.includes(:user).order(created_at: :asc).map { |reply| comment_with_metadata(reply) },
        upvotes_count: comment.upvotes.size,
        upvoted_by_current_user: current_user ? comment.upvotes.exists?(user_id: current_user.id) : false
      }
    end
  end
end 