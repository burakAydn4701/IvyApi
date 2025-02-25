module Api
  class UpvotesController < ApplicationController
    def create
      @voteable = find_voteable
      @upvote = @voteable.upvotes.new(user_id: params[:user_id])

      if @upvote.save
        render json: @voteable, status: :created
      else
        render json: { errors: @upvote.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @voteable = find_voteable
      @upvote = @voteable.upvotes.find_by(user_id: params[:user_id])

      if @upvote&.destroy
        render json: @voteable, status: :ok
      else
        render json: { error: "Upvote not found" }, status: :not_found
      end
    end

    private

    def find_voteable
      if params[:post_id]
        Post.find(params[:post_id])
      elsif params[:comment_id]
        Comment.find(params[:comment_id])
      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end 