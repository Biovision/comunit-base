class RegionsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity, only: [:edit, :update]
  before_action :restrict_editing, only: [:edit, :update]

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

  protected

  def restrict_access
    require_role :administrator
  end

  def set_entity
    @entity = Region.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find region')
    end
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
