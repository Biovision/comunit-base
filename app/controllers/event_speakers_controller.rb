class EventSpeakersController < AdminController
  before_action :set_entity, except: [:new, :create]

  # post /event_speakers
  def create
    @entity = EventSpeaker.new(creation_parameters)
    if @entity.save
      redirect_to(admin_event_path(id: @entity.event_id))
    else
      render :new, status: :bad_request
    end
  end

  # get /event_speakers/:id/edit
  def edit
  end

  # patch /event_speakers/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_event_path(id: @entity.event_id), notice: t('event_speakers.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /event_speakers/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('event_speakers.destroy.success')
    end
    redirect_to admin_event_path(id: @entity.event_id)
  end

  private

  def restrict_access
    require_privilege :event_manager
  end

  def set_entity
    @entity = EventSpeaker.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event speaker')
    end
  end

  def entity_parameters
    params.require(:event_speaker).permit(EventSpeaker.entity_parameters)
  end

  def creation_parameters
    params.require(:event_speaker).permit(EventSpeaker.creation_parameters)
  end
end
