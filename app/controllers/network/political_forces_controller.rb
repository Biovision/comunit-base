# frozen_string_literal: true

# RPC for political_forces
class Network::PoliticalForcesController < NetworkController

  private

  def set_handler
    @handler = NetworkManager::PoliticalForceHandler.new
  end
end
