# frozen_string_literal: true

# RPC for network regions
class Network::RegionsController < NetworkController
  before_action :set_handler

  # post /network/regions
  def create
    @handler.data = params.require(:data).permit!
    @entity = @handler.create_region
    if @entity.persisted?
      render :show, status: :created
    else
      render 'shared/forms/check', status: :bad_request
    end
  end

  # patch /network/regions/:id
  def update
    @handler.data = params.require(:data).permit!
    if @handler.update_region
      head :no_content
    else
      head :bad_request
    end
  end

  private

  def set_handler
    @handler = NetworkManager::RegionHandler.new
  end
end
