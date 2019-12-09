# frozen_string_literal: true

# RPC for posts
class Network::PostsController < NetworkController

  private

  def set_handler
    @handler = NetworkManager::PostHandler.new
  end
end
