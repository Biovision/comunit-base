class Network::SitesController < NetworkController
  # put /network/sites/:id
  def synchronize
    site = Site.find_by(id: params[:id]) || Site.new(id: params[:id])
    @manager.update_site(site, sync_parameters, params[:data])
    render json: { data: { site: site.attributes } }
  end

  private

  def sync_parameters
    params.require(:site).permit(Site.synchronization_parameters)
  end
end
