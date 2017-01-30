class Api::CitiesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity

  # put /api/cities/:id/lock
  def lock
    @entity.update! locked: true

    render json: { data: { locked: @entity.locked? } }
  end

  # delete /api/cities/:id/lock
  def unlock
    @entity.update! locked: false

    render json: { data: { locked: @entity.locked? } }
  end

  private

  def set_entity
    @entity = City.find_by id: params[:id]
    if @entity.nil? || @entity.deleted?
      handle_http_404 "Cannot find non-deleted city #{params[:id]}"
    end
  end

  def restrict_access
    require_role :administrator
  end
end
