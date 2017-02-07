class Api::RegionsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity

  # post /api/region/:id/toggle
  def toggle
    if @entity.editable_by?(current_user)
      render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
    else
      render json: { errors: { locked: @entity.locked } }, status: :forbidden
    end
  end

  # put /api/regions/:id/lock
  def lock
    require_role :administrator
    @entity.update! locked: true

    render json: { data: { locked: @entity.locked? } }
  end

  # delete /api/regions/:id/lock
  def unlock
    require_role :administrator
    @entity.update! locked: false

    render json: { data: { locked: @entity.locked? } }
  end

  private

  def set_entity
    @entity = Region.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find region')
    end
  end

  def restrict_access
    require_role :administrator
  end
end
