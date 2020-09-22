class Admin::EventProgramsController < AdminController
  before_action :set_entity

  # get /admin/event_programs/:id
  def show
  end

  protected

  def set_entity
    @entity = EventProgram.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event program')
    end
  end
end
