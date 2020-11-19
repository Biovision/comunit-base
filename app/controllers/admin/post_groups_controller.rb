# frozen_string_literal: true

# Managing post groups
class Admin::PostGroupsController < AdminController
  include CreateAndModifyEntities
  include ListAndShowEntities
  include EntityPriority
  include ToggleableEntity

  before_action :set_entity, except: %i[check create index new]

  private

  def component_class
    Biovision::Components::PostsComponent
  end

  def restrict_access
    error = 'Managing post groups is not allowed'
    handle_http_401(error) unless component_handler.allow?('chief_editor')
  end
end
