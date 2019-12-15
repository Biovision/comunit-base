# frozen_string_literal: true

# Managing campaigns
class CampaignsController < AdminController
  before_action :set_entity, only: %i[edit update destroy]

  # post /campaigns/check
  def check
    @entity = Campaign.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /campaigns/new
  def new
    @entity = Campaign.new
  end

  # post /campaigns
  def create
    @entity = Campaign.new(entity_parameters)
    if @entity.save
      NetworkCampaignSyncJob.perform_later(@entity.id)
      form_processed_ok(admin_campaign_path(id: @entity.id))
    else
      form_processed_with_error(:new)
    end
  end

  # get /campaigns/:id/edit
  def edit
  end

  # patch /campaigns/:id
  def update
    if @entity.update(entity_parameters)
      NetworkCampaignSyncJob.perform_later(@entity.id, false)
      form_processed_ok(admin_campaign_path(id: @entity.id))
    else
      form_processed_with_error(:edit)
    end
  end

  # delete /campaigns/:id
  def destroy
    flash[:notice] = t('campaigns.destroy.success') if @entity.destroy

    redirect_to(admin_campaigns_path)
  end

  protected

  def component_slug
    Biovision::Components::CampaignsComponent::SLUG
  end

  def set_entity
    @entity = Campaign.find_by(id: params[:id])
    handle_http_404('Cannot find campaign') if @entity.nil?
  end

  def entity_parameters
    params.require(:campaign).permit(Campaign.entity_parameters)
  end
end
