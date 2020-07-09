# frozen_string_literal: true

# Managing political_forces
class PoliticalForcesController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # post /political_forces/check
  def check
    @entity = PoliticalForce.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /political_forces/new
  def new
    @entity = PoliticalForce.new
  end

  # post /political_forces
  def create
    @entity = PoliticalForce.new(entity_parameters)
    if @entity.save
      NetworkPoliticalForceSyncJob.perform_later(@entity.id)
      form_processed_ok(admin_political_force_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /political_forces/:id/edit
  def edit
  end

  # patch /political_forces/:id
  def update
    if @entity.update(entity_parameters)
      NetworkPoliticalForceSyncJob.perform_later(@entity.id, true)
      form_processed_ok(admin_political_force_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /political_forces/:id
  def destroy
    flash[:notice] = t('political_forces.destroy.success') if @entity.destroy

    redirect_to admin_political_forces_path
  end

  private

  def component_class
    Biovision::Components::CampaignsComponent
  end

  def creation_parameters
    parameters = params.require(:political_force).permit(PoliticalForce.creation_parameters)
    parameters.merge(owner_for_entity)
  end

  def set_entity
    @entity = PoliticalForce.find_by(id: params[:id])
    handle_http_404('Cannot find political_force') if @entity.nil?
  end

  def entity_parameters
    params.require(:political_force).permit(PoliticalForce.entity_parameters)
  end
end
