module Api
  class UpvotesController < ApplicationController
    before_action :authenticate_user

    def create
      # Add debugging
      Rails.logger.info "Params received: #{params.inspect}"
      
      voteable = find_voteable
      upvote = voteable.upvotes.new(user: current_user)

      if upvote.save
        render json: { success: true, upvotes_count: voteable.upvotes.count }
      else
        render json: { success: false, errors: upvote.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      voteable = find_voteable
      upvote = voteable.upvotes.find_by(user: current_user)

      if upvote&.destroy
        render json: { success: true, upvotes_count: voteable.upvotes.count }
      else
        render json: { success: false, message: "Unable to remove upvote" }, status: :unprocessable_entity
      end
    end

    private

    def find_voteable
      if params[:post_id].present?
        Post.find(params[:post_id])
      elsif params[:comment_id].present?
        Comment.find(params[:comment_id])
      elsif params[:voteable_type].present? && params[:voteable_id].present?
        params[:voteable_type].constantize.find(params[:voteable_id])
      else
        raise ActionController::ParameterMissing, "Missing voteable parameters"
      end
    end
  end
end 