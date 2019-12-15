# frozen_string_literal: true

# Administrative part of campaigns management
class Admin::CampaignsController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/campaigns
  def index
    @collection = Campaign.list_for_administration
  end

  # get /admin/campaigns/:id
  def show
  end

  # get /admin/campaigns/:id/candidates
  def candidates
    @collection = @entity.candidates.list_for_administration
  end

  # get /admin/campaigns/:id/candidates/new
  def new_candidate
  end

  private

  def component_slug
    Biovision::Components::CampaignsComponent::SLUG
  end

  def set_entity
    @entity = Campaign.find_by(id: params[:id])
    handle_http_404('Cannot find campaign') if @entity.nil?
  end
end
