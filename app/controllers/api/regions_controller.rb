class Api::RegionsController < ApplicationController
  before_action :restrict_access
  before_action :set_entity

  # put /api/regions/:id/lock
  def lock
    @entity.update! locked: true

    render json: { data: { locked: @entity.locked? } }
  end

  # delete /api/regions/:id/lock
  def unlock
    @entity.update! locked: false

    render json: { data: { locked: @entity.locked? } }
  end

  private

  def set_entity
    @entity = Region.find params[:id]
  end

  def restrict_access
    require_role :administrator
  end
end
