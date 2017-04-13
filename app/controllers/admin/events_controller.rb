class Admin::EventsController < AdminController
  before_action :set_entity, except: [:index]

  # get /admin/events
  def index
    @collection = Event.page_for_administration(current_page)
  end

  # get /admin/events/:id
  def show
  end

  # get /admin/events/:id/users
  def participants
    @filter     = params[:filter] || Hash.new
    @collection = @entity.event_participants.page_for_administration(current_page, @filter)
  end
  
  # post /api/events/:id/toggle
  def toggle
    if @entity.locked?
      render json: { errors: { locked: @entity.locked } }, status: :forbidden
    else
      render json: { data: @entity.toggle_parameter(params[:parameter].to_s) }
    end
  end

  # put /api/events/:id/lock
  def lock
    @entity.update! locked: true

    render json: { data: { locked: @entity.locked? } }
  end

  # delete /api/events/:id/lock
  def unlock
    @entity.update! locked: false

    render json: { data: { locked: @entity.locked? } }
  end

  protected

  def restrict_access
    require_privilege :event_manager
  end

  def set_entity
    @entity = Event.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event')
    end
  end
end
