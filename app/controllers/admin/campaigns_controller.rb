# frozen_string_literal: true

# Administrative part of campaigns management
class Admin::CampaignsController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  include ToggleableEntity

  before_action :set_entity, except: %i[check create index new]

  # get /admin/campaigns/:id/candidates
  def candidates
    @collection = @entity.candidates.list_for_administration
  end

  # get /admin/campaigns/:id/candidates/new
  def new_candidate
  end

  private

  def component_class
    Biovision::Components::CampaignsComponent
  end
end
