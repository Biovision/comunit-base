# frozen_string_literal: true

# RPC for posts
class Network::PostsController < NetworkController
  before_action :set_handler

  # post /network/posts
  def create
    @handler.data = params.require(:data).permit!
    @entity = @handler.create_local
    if @entity.persisted?
      render :show, status: :created
    else
      render 'shared/forms/check', status: :bad_request
    end
  end

  private

  def set_handler
    @handler = NetworkManager::PostHandler.new
  end
end
