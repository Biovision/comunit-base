class Api::TokensController < ApplicationController
  before_action :restrict_access, except: [:toggle]
  before_action :set_entity, only: [:toggle]
  before_action :restrict_editing, only: [:toggle]

  # post /api/tokens/:id/toggle
  def toggle
    render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
  end

  private

  def set_entity
    @entity = Token.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find token')
    end
  end

  def restrict_editing
    unless @entity.editable_by?(current_user)
      handle_http_401('Token is not editable by current user')
    end
  end

  def restrict_access
    require_role :administrator
  end
end
