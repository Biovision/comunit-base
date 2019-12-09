# frozen_string_literal: true

# RPC for campaigns
class Network::CampaignsController < NetworkController

  private

  def set_handler
    @handler = NetworkManager::CampaignHandler.new
  end
end
