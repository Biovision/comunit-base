# frozen_string_literal: true

# RPC for network regions
class Network::RegionsController < NetworkController

  private

  def set_handler
    @handler = NetworkManager::RegionHandler.new
  end
end
