# frozen_string_literal: true

# Managing candidates
class CandidatesController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # post /candidates/check
  def check
    @entity = Candidate.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /candidates/new
  def new
    @entity = Candidate.new
  end

  # post /candidates
  def create
    @entity = Candidate.new(creation_parameters)
    if @entity.save
      NetworkCandidateSyncJob.perform_later(@entity.id)
      form_processed_ok(admin_candidate_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /candidates/:id/edit
  def edit
  end

  # patch /candidates/:id
  def update
    if @entity.update(entity_parameters)
      NetworkCandidateSyncJob.perform_later(@entity.id, true)
      form_processed_ok(admin_candidate_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /candidates/:id
  def destroy
    flash[:notice] = t('candidates.destroy.success') if @entity.destroy

    redirect_to(candidates_admin_campaign_path(id: @entity.campaign_id))
  end

  private

  def component_class
    Biovision::Components::CampaignsComponent
  end

  def creation_parameters
    parameters = params.require(:candidate).permit(Candidate.creation_parameters)
    parameters.merge(owner_for_entity)
  end

  def set_entity
    @entity = Candidate.find_by(id: params[:id])
    handle_http_404('Cannot find candidate') if @entity.nil?
  end

  def entity_parameters
    params.require(:candidate).permit(Candidate.entity_parameters)
  end
end
