# frozen_string_literal: true

# Managing sites
class SitesController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # post /sites/check
  def check
    @entity = Site.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /sites/new
  def new
    @entity = Site.new
  end

  # post /sites
  def create
    @entity = Site.new(entity_parameters)
    if @entity.save
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_site_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /sites/:id/edit
  def edit
  end

  # patch /sites/:id
  def update
    if @entity.update(entity_parameters)
      NetworkEntitySyncJob.perform_later(@entity.class.to_s, @entity.id)
      form_processed_ok(admin_site_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /sites/:id
  def destroy
    flash[:notice] = t('.success') if @entity.destroy

    redirect_to(admin_sites_path)
  end

  protected

  def component_class
    Biovision::Components::ComunitComponent
  end

  def set_entity
    @entity = Site.find_by(id: params[:id])
    handle_http_404('Cannot find site') if @entity.nil?
  end

  def entity_parameters
    params.require(:site).permit(Site.entity_parameters)
  end
end
