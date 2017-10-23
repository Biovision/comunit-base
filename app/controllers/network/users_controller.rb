class Network::UsersController < NetworkController
  # put /network/users/:id
  def synchronize
    manager = NetworkManager::UserHandler.new
    attr = params.require(:user).permit(User.relink_parameters + UserProfile.entity_parameters)
    user = User.find_by(external_id: params[:id])
    if user.nil?
      user = User.new(external_id: params[:id])
    end
    manager.update_user(user, attr, params[:data])
    render json: { data: { user: user.attributes } }
  end
end
