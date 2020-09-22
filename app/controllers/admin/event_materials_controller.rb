class Admin::EventMaterialsController < AdminController
  before_action :set_entity

  # post /admin/event_materials/:id/toggle
  def toggle
    if @entity.locked?
      render json: { errors: { locked: @entity.locked } }, status: :forbidden
    else
      render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
    end
  end

  private

  def set_entity
    @entity = EventMaterial.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event material')
    end
  end
end
