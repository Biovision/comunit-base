class EventProgramsController < AdminController
  before_action :set_entity, except: [:new, :create]

  # post /event_programs
  def create
    @entity = EventProgram.new(creation_parameters)
    if @entity.save
      redirect_to(admin_event_path(@entity.event_id))
    else
      render :new, status: :bad_request
    end
  end

  # get /event_programs/:id/edit
  def edit
  end

  # patch /event_programs/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_event_path(@entity.event_id), notice: t('event_programs.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /event_programs/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('event_programs.destroy.success')
    end
    redirect_to admin_event_path(@entity.event_id)
  end

  private

  def restrict_access
    require_privilege :event_manager
  end

  def set_entity
    @entity = EventProgram.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event program')
    end
  end

  def entity_parameters
    params.require(:event_program).permit(EventProgram.entity_parameters)
  end

  def creation_parameters
    params.require(:event_program).permit(EventProgram.creation_parameters)
  end
end
