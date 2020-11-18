# frozen_string_literal: true

# Administrative part for decisions
class Admin::DecisionsController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  include ToggleableEntity

  before_action :set_entity, except: %i[check create index new]

  private

  def component_class
    Biovision::Components::DecisionsComponent
  end
end
