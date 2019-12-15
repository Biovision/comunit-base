# frozen_string_literal: true

# Administrative part of political forces management
class Admin::PoliticalForcesController < AdminController
  before_action :set_entity, except: :index

  # get /admin/political_forces
  def index
    @collection = PoliticalForce.list_for_administration
  end

  # get /admin/political_forces/:id
  def show
  end

  # get /admin/political_forces/:id/candidates
  def candidates
    @collection = @entity.candidates.list_for_administration.page(current_page)
  end

  # put /admin/political_forces/:id/candidates/:candidate_id
  def add_candidate
    @entity.add_candidate(Candidate.find_by(id: params[:candidate_id]))

    head :no_content
  end

  # delete /admin/political_forces/:id/candidates/:candidate_id
  def remove_candidate
    @entity.remove_candidate(Candidate.find_by(id: params[:candidate_id]))

    head :no_content
  end

  private

  def component_slug
    Biovision::Components::CampaignsComponent::SLUG
  end

  def set_entity
    @entity = PoliticalForce.find_by(id: params[:id])
    handle_http_404('Cannot find political_force') if @entity.nil?
  end
end
