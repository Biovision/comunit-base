# frozen_string_literal: true

# Administrative part of candidates management
class Admin::CandidatesController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  include ToggleableEntity

  before_action :set_entity, except: %i[check create index new]

  private

  def component_class
    Biovision::Components::CampaignsComponent
  end
end
