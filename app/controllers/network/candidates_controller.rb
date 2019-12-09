# frozen_string_literal: true

# RPC for candidates
class Network::CandidatesController < NetworkController

  private

  def set_handler
    @handler = NetworkManager::CandidateHandler.new
  end
end
