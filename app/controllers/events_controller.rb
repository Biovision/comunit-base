class EventsController < ApplicationController
  before_action :restrict_access, except: [:index, :show]
  before_action :set_entity, except: [:index, :new, :create]

  layout 'admin', except: [:index, :show]

  # get /events
  def index
    @collection = Event.page_for_visitors(current_page)
  end

  # get /events/new
  def new
    @entity = Event.new
  end

  # post /events
  def create
    @entity = Event.new(entity_parameters)
    if @entity.save
      redirect_to(admin_event_path(id: @entity.id))
    else
      render :new, status: :bad_request
    end
  end

  # get /events/:id
  def show
    handle_http_404('Event is not visible') unless @entity.visible?
  end

  # get /events/:id/edit
  def edit
  end

  # patch /events/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_event_path(id: @entity.id), notice: t('events.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /events/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('events.destroy.success')
    end
    redirect_to admin_events_path
  end

  private

  def restrict_access
    require_privilege :event_manager
  end

  def set_entity
    @entity = Event.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404("Cannot find event #{params[:id]}")
    end
  end

  def entity_parameters
    params.require(:event).permit(Event.entity_parameters)
  end
end
