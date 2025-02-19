module Api
  class UpvotesController < ApplicationController
    def create
      @upvote = Upvote.new(upvote_params)
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
      params.require(:upvote).permit(:user_id, :voteable_type, :voteable_id)
    end
  end
end 