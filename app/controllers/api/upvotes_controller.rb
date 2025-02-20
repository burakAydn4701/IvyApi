module Api
  class UpvotesController < ApplicationController
    before_action :authenticate_user!

    def create
      @post = Post.find(params[:post_id])
      user = User.find(params[:user_id])

      if @post.upvotes.where(user: user).exists?
        render json: { error: "Already upvoted" }, status: :unprocessable_entity
      else
        @post.upvotes.create(user: user)
        render json: @post, status: :ok
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
      params.require(:upvote).permit(:post_id)
    end
  end
end 