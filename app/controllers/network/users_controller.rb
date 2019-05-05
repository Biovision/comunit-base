# frozen_string_literal: true

# RPC for posts
class Network::UsersController < NetworkController
  before_action :set_handler

  # post /network/users
  def create
    @handler.data = params.require(:data).permit!
    @entity = @handler.create_local
    if @entity.persisted?
      render :show, status: :created
    else
      render 'shared/forms/check', status: :bad_request
    end
  end

  # patch /network/users/:id
  def update
    @handler.data = params.require(:data).permit!
    if @handler.update_local
      head :no_content
    else
      head :bad_request
    end
  end

  # put /network/users/:id/uuid
  def update_uuid
    user = User.find_by(slug: params[:id])
    if user.nil?
      handle_http_404("Cannot find user with slug #{params[:id]}")
    else
      user.uuid = param_from_request(:uuid)
      head(user.save ? :no_content : :bad_request)
    end
  end

  private

  def set_handler
    @handler = NetworkManager::UserHandler.new
  end
end
