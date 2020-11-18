# frozen_string_literal: true

# Managing campaigns
class CampaignsController < ApplicationController
  before_action :set_entity, only: %i[edit update destroy]
  before_action :set_campaign, only: %i[candidate event join_team mandate mandates]
  before_action :set_candidate, only: %i[candidate join_team mandates]

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

  protected

  def component_class
    Biovision::Components::CampaignsComponent
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
