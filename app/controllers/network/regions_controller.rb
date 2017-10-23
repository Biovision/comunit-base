class Network::RegionsController < NetworkController
  # put /network/regions/:id
  def synchronize
    manager = NetworkManager.new
    region  = Region.find_by(id: params[:id]) || Region.new(id: params[:id])
    manager.update_region(region, sync_parameters, params[:data])
    render json: { data: { region: region.attributes } }
  end

  private

  def sync_parameters
    params.require(:region).permit(Region.synchronization_parameters)
  end
end
