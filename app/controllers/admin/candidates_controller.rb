# frozen_string_literal: true

# Administrative part of candidates management
class Admin::CandidatesController < AdminController
  include ToggleableEntity

  before_action :set_entity, except: :index

  # get /admin/candidates
  def index
    @collection = Candidate.list_for_administration.page(current_page)
  end

  # get /admin/candidates/:id
  def show
  end

  private

  def component_slug
    Biovision::Components::CampaignsComponent::SLUG
  end

  def set_entity
    @entity = Candidate.find_by(id: params[:id])
    handle_http_404('Cannot find candidate') if @entity.nil?
  end
end
