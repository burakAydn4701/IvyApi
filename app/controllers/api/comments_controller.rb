module Api
  class CommentsController < ApplicationController
    before_action :authenticate_user, except: [:index, :show]

    def index
      @post = Post.find(params[:post_id])
      @comments = @post.comments.includes(:user, :replies)
      
      render json: @comments.map { |comment|
        comment.as_json(
          include: {
            user: { only: [:id, :username] },
            replies: { 
              include: { user: { only: [:id, :username] } },
              methods: [:replies_count, :upvotes_count]
            }
          },
          methods: [:replies_count, :upvotes_count]
        ).merge(upvoted_by_current_user: comment.upvoted_by_current_user(current_user))
      }
    end

    def show
      @comment = Comment.find(params[:id])
      render json: @comment.as_json(
        include: {
          replies: { 
            include: { 
              user: { only: [:id, :username] },
              replies: { include: :user }
            }
          },
          user: { only: [:id, :username] }
        },
        methods: [:upvotes_count]
      ).merge(upvoted_by_current_user: @comment.upvoted_by_current_user(current_user))
    end

    def create
      if params[:post_id]
        # Creating a comment on a post
        @post = Post.find(params[:post_id])
        @comment = @post.comments.new(comment_params)
      elsif params[:comment_id]
        # Creating a reply to a comment
        parent_comment = Comment.find(params[:comment_id])
        @comment = Comment.new(comment_params)
        @comment.post = parent_comment.post
        @comment.parent = parent_comment
      end
      
      if @comment&.save
        render json: @comment, status: :created
      else
        render json: { errors: @comment&.errors&.full_messages || ["Invalid parameters"] }, status: :unprocessable_entity
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

    def destroy
      @comment = Comment.find(params[:id])
      
      if @comment.destroy
        render json: { message: "Comment deleted successfully" }, status: :ok
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def comment_params
      params.require(:comment).permit(:content, :user_id)
    end
  end
end 