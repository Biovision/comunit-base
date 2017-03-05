class Admin::PrivilegesController < ApplicationController
  include Biovision::Admin::Privileges

  # post /api/privileges/:id/toggle
  def toggle
    if @entity.locked?
      render json: { errors: { locked: @entity.locked } }, status: :forbidden
    else
      render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
    end
  end
end
