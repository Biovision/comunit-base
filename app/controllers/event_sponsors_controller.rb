class EventSponsorsController < AdminController
  before_action :set_entity, except: [:new, :create]

  # post /event_sponsors
  def create
    @entity = EventSponsor.new(creation_parameters)
    if @entity.save
      redirect_to(admin_event_path(id: @entity.event_id))
    else
      render :new, status: :bad_request
    end
  end

  # get /event_sponsors/:id/edit
  def edit
  end

  # patch /event_sponsors/:id
  def update
    if @entity.update(entity_parameters)
      redirect_to admin_event_path(id: @entity.event_id), notice: t('event_sponsors.update.success')
    else
      render :edit, status: :bad_request
    end
  end

  # delete /event_sponsors/:id
  def destroy
    if @entity.destroy
      flash[:notice] = t('event_sponsors.destroy.success')
    end
    redirect_to admin_event_path(id: @entity.event_id)
  end

  private

  def set_entity
    @entity = EventSponsor.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event sponsor')
    end
  end

  def entity_parameters
    params.require(:event_sponsor).permit(EventSponsor.entity_parameters)
  end

  def creation_parameters
    params.require(:event_sponsor).permit(EventSponsor.creation_parameters)
  end
end
