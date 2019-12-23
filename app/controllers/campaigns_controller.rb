# frozen_string_literal: true

# Managing campaigns
class CampaignsController < ApplicationController
  before_action :restrict_access, only: %i[check new create edit update destroy]
  before_action :set_entity, only: %i[edit update destroy]
  before_action :set_campaign, only: %i[candidate event join_team mandate mandates]
  before_action :set_candidate, only: %i[candidate join_team mandates]

  layout 'admin', only: %i[check new create edit update destroy]

  # post /campaigns/check
  def check
    @entity = Campaign.instance_for_check(params[:entity_id], entity_parameters)

    render 'shared/forms/check'
  end

  # get /campaigns
  def index
    @collection = Campaign.list_for_visitors
  end

  # get /campaigns/:id
  def show
    @entity = Campaign.list_for_visitors.find_by(slug: params[:id])
    handle_http_404('Cannot find campaign') if @entity.nil?
  end

  # get /campaigns/:id/candidate-:candidate_id
  def candidate
  end

  # get /campaigns/:id/mandate-:mandate_id
  def mandate
    @mandate = @entity.mandates.list_for_visitors.find_by(id: params[:mandate_id])

    handle_http_404('Cannot find mandate for campaign') if @mandate.nil?
  end

  # get /campaigns/:id/candidate-:candidate_id/mandates
  def mandates
    @collection = @candidate.mandates.list_for_visitors # .page(current_page)
  end

  # post /campaigns/:id/candidate-:candidate_id/join
  def join_team
    role = param_from_request(:role)
    @candidate.add_user(current_user, role)

    render json: { meta: { message: t('campaigns.join_team.pending') } }
  end

  # get /campaigns/:id/event-:event_id
  def event
    @event = @entity.events.list_for_visitors.find_by(id: params[:event_id])

    handle_http_404('Cannot find event for campaign') if @event.nil?
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

  def restrict_access
    error = "User #{current_user&.id} has no privileges"

    handle_http_401(error) unless component_handler.allow?
  end

  def set_entity
    @entity = Campaign.find_by(id: params[:id])
    handle_http_404('Cannot find campaign') if @entity.nil?
  end

  def set_campaign
    @entity = Campaign.list_for_visitors.find_by(slug: params[:id])
    handle_http_404('Cannot find campaign') if @entity.nil?
  end

  def set_candidate
    criteria = { id: params[:candidate_id] }
    @candidate = @entity.candidates.list_for_visitors.find_by(criteria)

    handle_http_404('Cannot find candidate for campaign') if @candidate.nil?
  end

  def entity_parameters
    params.require(:campaign).permit(Campaign.entity_parameters)
  end
end
