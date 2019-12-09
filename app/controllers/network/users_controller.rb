# frozen_string_literal: true

# RPC for posts
class Network::UsersController < NetworkController
  # put /network/users/:id/uuid
  def update_uuid
    user = User.find_by(slug: params[:id])
    if user.nil?
      handle_http_404("Cannot find user with slug #{params[:id]}")
    else
      user.uuid = param_from_request(:uuid)
      user.email = param_from_request(:email) unless user.valid?
      head(user.save ? :no_content : :bad_request)
    end
  end

  private

  def set_handler
    @handler = NetworkManager::UserHandler.new
  end
end
