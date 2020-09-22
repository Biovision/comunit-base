class Admin::EventParticipantsController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: [:index]

  # get /admin/event_participants
  def index
    @collection = EventParticipant.page_for_administration(current_page)
  end

  # get /admin/event_participants/:id
  def show
  end

  protected

  def set_entity
    @entity = EventParticipant.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event participant')
    end
  end
end
