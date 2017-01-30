class RegionsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, only: [:edit, :update, :destroy]
  before_action :restrict_editing, only: [:edit, :update, :destroy]

  # get /regions/new
  def new
    @entity = Region.new
  end

  # post /regions
  def create
    @entity = Region.new entity_parameters
    if @entity.save
      redirect_to admin_region_path(@entity)
    else
      render :new, status: :bad_request
    end
  end

  # get /regions/:id/edit
  def edit
  end

  # patch /regions/:id
  def update
    if @entity.update entity_parameters
      redirect_to admin_region_path(@entity), notice: t('regions.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /regions/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('regions.destroy.success')
    end
    redirect_to admin_regions_path
  end

  protected

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = Region.find params[:id]
  end

  def restrict_editing
    if @entity.locked?
      redirect_to admin_region_path(@entity), alert: t('regions.edit.forbidden')
    end
  end

  def entity_parameters
    params.require(:region).permit(Region.entity_parameters)
  end
end
