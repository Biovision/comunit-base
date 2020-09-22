class Admin::EventSponsorsController < AdminController
  before_action :set_entity

  # post /admin/event_sponsors/:id/toggle
  def toggle
    if @entity.locked?
      render json: { errors: { locked: @entity.locked } }, status: :forbidden
    else
      render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
    end
  end

  # post /admin/event_sponsors/:id/priority
  def priority
    render json: { data: @entity.change_priority(params[:delta].to_s.to_i) }
  end

  private

  def set_entity
    @entity = EventSponsor.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event sponsor')
    end
  end
end
