# app/controllers/api/communities_controller.rb
module Api
  class CommunitiesController < ApplicationController
    # GET /api/communities
    def index
      communities = Community.all
      render json: communities
    end

    # GET /api/communities/:id
    def show
      community = Community.find(params[:id])
      render json: community
    end

    # POST /api/communities
    def create
      Rails.logger.info "Params received: #{params.inspect}"
      @community = Community.new(community_params)
      
      @community.attach_profile_picture(params[:community][:profile_photo]) if params[:community][:profile_photo].present?
      @community.attach_banner(params[:community][:banner]) if params[:community][:banner].present?

      if @community.save
        Rails.logger.info "Community saved successfully"
        render json: @community, status: :created
      else
        Rails.logger.error "Community save failed: #{@community.errors.full_messages}"
        render json: { error: @community.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/communities/:id
    def update
      community = Community.find(params[:id])
      if community.update(community_params)
        render json: community
      else
        render json: community.errors, status: :unprocessable_entity
      end
    end

    # DELETE /api/communities/:id
    def destroy
      community = Community.find(params[:id])
      community.destroy
      head :no_content
    end

    private

    def community_params
      params.require(:community).permit(:name, :description, :profile_photo, :banner)
    end
  end
end