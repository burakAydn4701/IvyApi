module Api
  class UpvotesController < ApplicationController
    before_action :authenticate_user!

    def create
      voteable = find_voteable
      upvote = voteable.upvotes.new(user: current_user)

      if upvote.save
        render json: { success: true, upvotes_count: voteable.upvotes.count }
      else
        render json: { success: false, errors: upvote.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @voteable = find_voteable
      @upvote = @voteable.upvotes.find_by(user_id: params[:user_id])

      if @upvote
        @upvote.destroy
        render json: @voteable, status: :ok
      else
        render json: { error: "Upvote not found" }, status: :not_found
      end
    end

    private

    def find_voteable
      params[:voteable_type].constantize.find(params[:voteable_id])
    end
  end
end 