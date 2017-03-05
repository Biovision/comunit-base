class CitiesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # post /cities
  def create
    @entity = City.new creation_parameters
    if @entity.save
      redirect_to admin_region_path(@entity.region_id)
    else
      render :new, status: :bad_request
    end
  end

  # get /cities/:id/edit
  def edit
  end

  # patch /cities/:id
  def update
    if @entity.update entity_parameters
      redirect_to admin_region_path(@entity.region_id), notice: t('cities.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /cities/:id
  def destroy
    if @entity.update(deleted: true)
      flash[:notice] = t('cities.destroy.success')
    end
    redirect_to admin_region_path(@entity.region_id)
  end

  protected

  def restrict_access
    require_privilege :administrator
  end

  def set_entity
    @entity = City.find_by(id: params[:id])
    if @entity.nil? || @entity.deleted?
      handle_http_404 "Cannot find non-deleted city #{params[:id]}"
    end
  end

  def restrict_editing
    if @entity.locked?
      redirect_to admin_region_path(@entity.region_id), alert: t('cities.edit.forbidden')
    end
  end

  def entity_parameters
    params.require(:city).permit(City.entity_parameters)
  end

  def creation_parameters
    params.require(:city).permit(City.creation_parameters)
  end
end
