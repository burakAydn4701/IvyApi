module Api
  class UpvotesController < ApplicationController
    def create
      @upvote = if upvote_params[:post_id]
        # Upvoting a post
        Upvote.new(
          user_id: upvote_params[:user_id],
          voteable_type: 'Post',
          voteable_id: upvote_params[:post_id]
        )
      elsif upvote_params[:comment_id]
        # Upvoting a comment
        Upvote.new(
          user_id: upvote_params[:user_id],
          voteable_type: 'Comment',
          voteable_id: upvote_params[:comment_id]
        )
      end

      if @upvote.save
        render json: @upvote, status: :created
      else
        render json: @upvote.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @upvote = Upvote.find_by!(
        user_id: params[:user_id],
        voteable_type: params[:voteable_type],
        voteable_id: params[:voteable_id]
      )
      @upvote.destroy
      head :no_content
    end

    private

    def upvote_params
      params.require(:upvote).permit(:user_id, :post_id, :comment_id)
    end
  end
end 