class Network::UsersController < NetworkController
  # put /network/users/:id
  def synchronize
    user = User.find_by(external_id: params[:id]) || User.new(external_id: params[:id])
    @manager.update_user(user, sync_parameters, params[:data])
    render json: { data: { user: user.attributes } }
  end

  private

  def sync_parameters
    params.require(:user).permit(User.synchronization_parameters)
  end
end
