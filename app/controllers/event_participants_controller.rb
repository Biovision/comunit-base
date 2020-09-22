class EventParticipantsController < ApplicationController
  before_action :restrict_access, except: [:create]
  before_action :set_entity, only: [:destroy]

  def create
    @entity = EventParticipant.new(creation_parameters)
    if @entity.save
      Metric.register(EventParticipant::METRIC_CREATED)
      redirect_to event_path(id: @entity.event_id), notice: t('event_participants.create.success')
    else
      render :new, status: :bad_request
    end
  end

  # delete /event_participants/:id
  def destroy
    @entity.destroy
    redirect_to admin_event_path(id: @entity.event_id)
  end

  private

  def set_entity
    @entity = EventParticipant.find_by(id: params[:id])
    if @entity.nil?
      handle_http_404('Cannot find event_participant')
    end
  end

  def restrict_access
    handle_http_403('Forbidden') unless current_user&.super_user?
  end

  def entity_parameters
    permitted = EventParticipant.entity_parameters
    params.require(:event_participant).permit(permitted)
  end

  def creation_parameters
    permitted  = EventParticipant.creation_parameters
    parameters = params.require(:event_participant).permit(permitted)
    parameters.merge(owner_for_entity(true))
  end
end
