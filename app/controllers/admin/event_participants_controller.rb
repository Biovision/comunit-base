class Admin::EventParticipantsController < AdminController
  before_action :set_entity

  # get /admin/event_participants
  def index
    @collection = EventParticipant.page_for_administration(current_page)
  end

  # get /admin/event_participants/:id
  def show
  end

  # post /api/event_participants/:id/toggle
  def toggle
    render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
  end

  protected

  def restrict_access
    require_privilege :event_manager
  end

  def set_entity
    @entity = EventParticipant.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event participant')
    end
  end
end
