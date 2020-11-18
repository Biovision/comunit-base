# frozen_string_literal: true

# Administrative part of political forces management
class Admin::PoliticalForcesController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  before_action :set_entity, except: %i[check create index new]

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

  def component_class
    Biovision::Components::CampaignsComponent
  end
end
