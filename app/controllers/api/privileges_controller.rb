class Api::PrivilegesController < ApplicationController
  before_action :restrict_access
  before_action :set_entity

  # post /api/privileges/:id/toggle
  def toggle
    if @entity.locked?
      render json: { errors: { locked: @entity.locked } }, status: :forbidden
    else
      render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
    end
  end

  # put /api/privileges/:id/lock
  def lock
    @entity.update! locked: true

    render json: { data: { locked: @entity.locked? } }
  end

  # delete /api/privileges/:id/lock
  def unlock
    @entity.update! locked: false

    render json: { data: { locked: @entity.locked? } }
  end

  # post /api/privileges/:id/priority
  def priority
    @entity.change_priority(params[:delta].to_s.to_i)

    render json: { data: { priority: @entity.priority } }
  end

  private

  def set_entity
    @entity = Privilege.find_by(id: params[:id], deleted: false)
    if @entity.nil?
      handle_http_404('Cannot find non-deleted privilege')
    end
  end

  def restrict_access
    require_role :administrator
  end
end